// --------------------------------------------------------------------------
// obs-metal-fisheye-filter.cpp
// --------------------------------------------------------------------------

#include <obs-module.h>
#include <CoreFoundation/CoreFoundation.h> // For finding the Metal library
#include <Metal/Metal.h>                 // For Metal API access

// --- OBS Data Structures for the Filter (Simplified) ---
typedef struct {
    obs_source_t *context;

    // Settings
    float fov_degrees;
    float pan_degrees;  // Rotation around Y-axis (vertical)
    float tilt_degrees; // Rotation around X-axis (horizontal)
    float yaw_degrees;  // Rotation around Z-axis (depth/camera-facing)
    float alpha_level;  // Alpha for the area outside the circle (0.0 to 1.0)

    // Metal Objects (Pointers to Objective-C objects)
    id<MTLDevice> metal_device;
    id<MTLLibrary> metal_library;
    id<MTLComputePipelineState> compute_pipeline;
    id<MTLCommandQueue> command_queue;

} fisheye_filter_data_t;


// --- 1. Filter Registration and Setup ---

const char *fisheye_filter_get_name(void *unused)
{
    return obs_module_text("FisheyeMetalFilter");
}

void fisheye_filter_defaults(obs_data_t *settings)
{
    obs_data_set_default_double(settings, "fov_degrees", 180.0);
    obs_data_set_default_double(settings, "pan_degrees", 0.0);
    obs_data_set_default_double(settings, "tilt_degrees", 0.0);
    obs_data_set_default_double(settings, "yaw_degrees", 0.0);
    obs_data_set_default_double(settings, "alpha_level", 0.0); // Default: fully transparent
}

// Function to load the pre-compiled Metal Library
bool load_metal_library(fisheye_filter_data_t *data)
{
    // WARNING: This is a complex step on a real plugin!
    // It requires finding the .metallib file bundled with the plugin bundle,
    // and then loading it with the Metal API.

    // 1. Get the OBS Metal device (requires OBS internal API access, PEEKING)
    // For OBS, you'd typically get the device from gs_device_metal or similar.
    // Placeholder: Assume the device is available and assigned to data->metal_device

    // 2. Load the library (Conceptual Code)
    NSError *error = nil;
    /*
    NSString *libraryPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"equirectToFisheye" ofType:@"metallib"];
    NSData *libraryData = [NSData dataWithContentsOfFile:libraryPath];
    data->metal_library = [data->metal_device newLibraryWithData:libraryData error:&error];
    if (!data->metal_library) {
        blog(LOG_ERROR, "Failed to create MTLLibrary: %s", error.localizedDescription.UTF8String);
        return false;
    }

    // 3. Create the function and pipeline
    id<MTLFunction> kernelFunction = [data->metal_library newFunctionWithName:@"equirectToFisheye"];
    if (!kernelFunction) {
        blog(LOG_ERROR, "Failed to find Metal kernel 'equirectToFisheye'");
        return false;
    }
    
    data->compute_pipeline = [data->metal_device newComputePipelineStateWithFunction:kernelFunction error:&error];
    if (!data->compute_pipeline) {
        blog(LOG_ERROR, "Failed to create MTLComputePipelineState: %s", error.localizedDescription.UTF8String);
        return false;
    }
    
    data->command_queue = [data->metal_device newCommandQueue];
    */
    // For simplicity, we'll assume success in this framework.
    return true;
}

void *fisheye_filter_create(obs_data_t *settings, obs_source_t *context)
{
    fisheye_filter_data_t *data = bzalloc(sizeof(*data));
    data->context = context;

    // Load Metal resources upon creation
    if (!load_metal_library(data)) {
        // Handle error: free memory, return NULL
        bfree(data);
        return NULL;
    }

    return data;
}

void fisheye_filter_destroy(void *vdata)
{
    fisheye_filter_data_t *data = (fisheye_filter_data_t *)vdata;

    // Release Metal objects (since they are Objective-C objects, use release or ARC cleanup)
    // [data->compute_pipeline release]; // or use ARC

    bfree(data);
}

// --- 2. Filter Execution (Render) ---

obs_source_t *fisheye_filter_render(void *vdata, gs_effect_t *effect)
{
    fisheye_filter_data_t *data = (fisheye_filter_data_t *)vdata;
    obs_source_t *input = obs_filter_get_target(data->context);

    if (!input)
        return NULL;

    // 1. Get Input and Output Textures (OBS Graphics API)
    gs_texture_t *input_texture = obs_source_get_texture(input);
    // You would need to create a new gs_texture_t for the output that uses Metal resources.
    // Placeholder for OBS texture management:
    // gs_texture_t *output_texture = obs_filter_get_target_texture(data->context);
    
    if (input_texture) {
        // --- Execute the Metal Compute Shader (Conceptual Metal API calls) ---

        // 2. Set up the command buffer
        /*
        id<MTLCommandBuffer> commandBuffer = [data->command_queue commandBuffer];
        id<MTLComputeCommandEncoder> computeEncoder = [commandBuffer computeCommandEncoder];

        // 3. Bind the pipeline and resources
        [computeEncoder setComputePipelineState:data->compute_pipeline];
        
        // Input Texture: gs_texture_t needs to be unwrapped to its MTLTexture pointer
        id<MTLTexture> input_metal_tex = get_metal_texture(input_texture); 
        [computeEncoder setTexture:input_metal_tex atIndex:0];

        // Output Texture (e.g., from an internal render target)
        id<MTLTexture> output_metal_tex = get_metal_texture(output_texture);
        [computeEncoder setTexture:output_metal_tex atIndex:1];

        // 4. Update and Bind Uniforms (Constants)
        Uniforms uniforms = {
            .fov_radians = data->fov_degrees * (float)M_PI / 180.0f,
            .aspect_ratio = (float)output_metal_tex.width / (float)output_metal_tex.height,
            .time = (float)obs_get_video_frame_time() / (float)NSEC_PER_SEC,
        
            // NEW PARAMETERS
            .pan_radians = data->pan_degrees * (float)M_PI / 180.0f,
            .tilt_radians = data->tilt_degrees * (float)M_PI / 180.0f,
            .yaw_radians = data->yaw_degrees * (float)M_PI / 180.0f,
            .alpha_level = data->alpha_level,
        };
        
        // Create an MTLBuffer for the uniforms
        id<MTLBuffer> uniformBuffer = [data->metal_device newBufferWithBytes:&uniforms 
                                                                     length:sizeof(Uniforms) 
                                                                    options:MTLResourceStorageModeShared];
        [computeEncoder setBuffer:uniformBuffer offset:0 atIndex:0];

        // 5. Calculate and dispatch thread groups
        MTLSize threadsPerGroup = MTLSizeMake(16, 16, 1);
        MTLSize threadGroups = MTLSizeMake(
            (output_metal_tex.width + threadsPerGroup.width - 1) / threadsPerGroup.width,
            (output_metal_tex.height + threadsPerGroup.height - 1) / threadsPerGroup.height,
            1);

        [computeEncoder dispatchThreadgroups:threadGroups threadsPerThreadgroup:threadsPerGroup];
        [computeEncoder endEncoding];
        
        // 6. Commit the command buffer for execution
        [commandBuffer commit];
        [commandBuffer waitUntilCompleted];
        */

        // 7. Return the processed output texture (as an obs_source_t wrapper)
        // return obs_filter_get_target_source(data->context);
    }

    // Fallback: If no processing was done, return the original input
    obs_source_inc_showing(input);
    return input;
}


// --- 3. OBS Module Definition ---

struct obs_source_info fisheye_filter_info = {
    .id = "metal_fisheye_filter",
    .type = OBS_SOURCE_TYPE_FILTER,
    .output_flags = OBS_SOURCE_VIDEO,
    .get_name = fisheye_filter_get_name,
    .create = fisheye_filter_create,
    .destroy = fisheye_filter_destroy,
    .get_defaults = fisheye_filter_defaults,
    .video_render = fisheye_filter_render,
    // .get_properties = fisheye_filter_get_properties, // For user settings
};

// Module setup function
OBS_DECLARE_MODULE()
OBS_MODULE_AUTHOR("Your Name")
OBS_MODULE_DESCRIPTION("Equirectangular to Fisheye Projection using Metal")
OBS_MODULE_EXPORT bool obs_module_load(void)
{
    obs_register_source(&fisheye_filter_info);
    return true;
}
