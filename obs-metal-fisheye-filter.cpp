// --------------------------------------------------------------------------
// obs-metal-fisheye-filter.cpp
// --------------------------------------------------------------------------

#include <obs-module.h>
#include <CoreFoundation/CoreFoundation.h> // For finding the Metal library
#include <Metal/Metal.h>                 // For Metal API access
#include <graphics/graphics.h>
#include <graphics/graphics-internal.h>
#include <util/platform.h>
#include <util/threading.h>
#include <string>

// Metal shader uniforms structure (must match the Metal shader)
struct Uniforms {
    float fov_radians;
    float aspect_ratio;
    float time;
    float center_x;
    float center_y;
    float pan_radians;
    float tilt_radians;
    float yaw_radians;
    float alpha_level;
};

// --- OBS Data Structures for the Filter ---
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
    id<MTLFunction> compute_function;
    id<MTLComputePipelineState> compute_pipeline;
    id<MTLCommandQueue> command_queue;
    id<MTLBuffer> uniform_buffer;

    // Thread safety
    pthread_mutex_t mutex;

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

void fisheye_filter_update(void *vdata, obs_data_t *settings)
{
    fisheye_filter_data_t *data = (fisheye_filter_data_t *)vdata;
    
    pthread_mutex_lock(&data->mutex);
    
    data->fov_degrees = (float)obs_data_get_double(settings, "fov_degrees");
    data->pan_degrees = (float)obs_data_get_double(settings, "pan_degrees");
    data->tilt_degrees = (float)obs_data_get_double(settings, "tilt_degrees");
    data->yaw_degrees = (float)obs_data_get_double(settings, "yaw_degrees");
    data->alpha_level = (float)obs_data_get_double(settings, "alpha_level");
    
    pthread_mutex_unlock(&data->mutex);
}

obs_properties_t *fisheye_filter_get_properties(void *vdata)
{
    UNUSED_PARAMETER(vdata);
    
    obs_properties_t *props = obs_properties_create();
    
    obs_properties_add_float_slider(props, "fov_degrees", 
        obs_module_text("FOV"), 0.0, 360.0, 1.0);
    
    obs_properties_add_float_slider(props, "pan_degrees", 
        obs_module_text("Pan"), -180.0, 180.0, 1.0);
    
    obs_properties_add_float_slider(props, "tilt_degrees", 
        obs_module_text("Tilt"), -180.0, 180.0, 1.0);
    
    obs_properties_add_float_slider(props, "yaw_degrees", 
        obs_module_text("Yaw"), -180.0, 180.0, 1.0);
    
    obs_properties_add_float_slider(props, "alpha_level", 
        obs_module_text("Alpha"), 0.0, 1.0, 0.01);
    
    return props;
}

// Function to load the Metal Library
bool load_metal_library(fisheye_filter_data_t *data)
{
    // Get the Metal device from OBS graphics system
    gs_device_t *device = gs_get_device();
    if (!device) {
        blog(LOG_ERROR, "Failed to get OBS graphics device");
        return false;
    }
    
    // Get Metal device from OBS (this requires internal API access)
    // For now, we'll create a new Metal device
    data->metal_device = MTLCreateSystemDefaultDevice();
    if (!data->metal_device) {
        blog(LOG_ERROR, "Failed to create Metal device");
        return false;
    }
    
    // Load the Metal library from the plugin bundle
    NSError *error = nil;
    
    // Get the plugin bundle path
    CFBundleRef bundle = CFBundleGetBundleWithIdentifier(CFSTR("com.obsproject.obs-studio"));
    if (!bundle) {
        // Fallback: try to find the plugin bundle
        bundle = CFBundleGetMainBundle();
    }
    
    if (bundle) {
        CFURLRef bundleURL = CFBundleCopyBundleURL(bundle);
        if (bundleURL) {
            CFStringRef bundlePath = CFURLCopyFileSystemPath(bundleURL, kCFURLPOSIXPathStyle);
            if (bundlePath) {
                NSString *bundlePathStr = (__bridge NSString *)bundlePath;
                NSString *libraryPath = [bundlePathStr stringByAppendingPathComponent:@"Contents/Resources/equirectangular_to_fisheye.metallib"];
                
                NSData *libraryData = [NSData dataWithContentsOfFile:libraryPath];
                if (libraryData) {
                    data->metal_library = [data->metal_device newLibraryWithData:libraryData error:&error];
                } else {
                    // Try to compile from source
                    NSString *sourcePath = [bundlePathStr stringByAppendingPathComponent:@"Contents/Resources/equirectangular_to_fisheye.metal"];
                    NSString *source = [NSString stringWithContentsOfFile:sourcePath encoding:NSUTF8StringEncoding error:&error];
                    if (source) {
                        data->metal_library = [data->metal_device newLibraryWithSource:source options:nil error:&error];
                    }
                }
                
                CFRelease(bundlePath);
            }
            CFRelease(bundleURL);
        }
    }
    
    if (!data->metal_library) {
        blog(LOG_ERROR, "Failed to create MTLLibrary: %s", error ? error.localizedDescription.UTF8String : "Unknown error");
        return false;
    }
    
    // Create the compute function
    data->compute_function = [data->metal_library newFunctionWithName:@"equirectToFisheye"];
    if (!data->compute_function) {
        blog(LOG_ERROR, "Failed to find Metal kernel 'equirectToFisheye'");
        return false;
    }
    
    // Create the compute pipeline
    data->compute_pipeline = [data->metal_device newComputePipelineStateWithFunction:data->compute_function error:&error];
    if (!data->compute_pipeline) {
        blog(LOG_ERROR, "Failed to create MTLComputePipelineState: %s", error.localizedDescription.UTF8String);
        return false;
    }
    
    // Create command queue
    data->command_queue = [data->metal_device newCommandQueue];
    if (!data->command_queue) {
        blog(LOG_ERROR, "Failed to create MTLCommandQueue");
        return false;
    }
    
    // Create uniform buffer
    data->uniform_buffer = [data->metal_device newBufferWithLength:sizeof(Uniforms) options:MTLResourceStorageModeShared];
    if (!data->uniform_buffer) {
        blog(LOG_ERROR, "Failed to create uniform buffer");
        return false;
    }
    
    return true;
}

void *fisheye_filter_create(obs_data_t *settings, obs_source_t *context)
{
    fisheye_filter_data_t *data = bzalloc(sizeof(*data));
    data->context = context;
    
    // Initialize mutex
    pthread_mutex_init(&data->mutex, NULL);
    
    // Load settings
    fisheye_filter_update(data, settings);

    // Load Metal resources upon creation
    if (!load_metal_library(data)) {
        // Handle error: free memory, return NULL
        pthread_mutex_destroy(&data->mutex);
        bfree(data);
        return NULL;
    }

    return data;
}

void fisheye_filter_destroy(void *vdata)
{
    fisheye_filter_data_t *data = (fisheye_filter_data_t *)vdata;

    // Release Metal objects (ARC will handle this automatically)
    // The Objective-C objects will be released when the struct is freed
    
    pthread_mutex_destroy(&data->mutex);
    bfree(data);
}

// --- 2. Filter Execution (Render) ---

obs_source_t *fisheye_filter_render(void *vdata, gs_effect_t *effect)
{
    UNUSED_PARAMETER(effect);
    
    fisheye_filter_data_t *data = (fisheye_filter_data_t *)vdata;
    obs_source_t *input = obs_filter_get_target(data->context);

    if (!input)
        return NULL;

    // Get input texture
    gs_texture_t *input_texture = obs_source_get_texture(input);
    if (!input_texture) {
        obs_source_inc_showing(input);
        return input;
    }
    
    // Get output dimensions
    uint32_t width = obs_source_get_width(input);
    uint32_t height = obs_source_get_height(input);
    
    if (width == 0 || height == 0) {
        obs_source_inc_showing(input);
        return input;
    }
    
    pthread_mutex_lock(&data->mutex);
    
    // Update uniforms
    Uniforms uniforms = {
        .fov_radians = data->fov_degrees * (float)M_PI / 180.0f,
        .aspect_ratio = (float)width / (float)height,
        .time = (float)obs_get_video_frame_time() / 1000000000.0f, // Convert to seconds
        .center_x = 0.5f,
        .center_y = 0.5f,
        .pan_radians = data->pan_degrees * (float)M_PI / 180.0f,
        .tilt_radians = data->tilt_degrees * (float)M_PI / 180.0f,
        .yaw_radians = data->yaw_degrees * (float)M_PI / 180.0f,
        .alpha_level = data->alpha_level,
    };
    
    // Copy uniforms to buffer
    memcpy([data->uniform_buffer contents], &uniforms, sizeof(Uniforms));
    
    pthread_mutex_unlock(&data->mutex);
    
    // For now, we'll use a simplified approach that doesn't require Metal integration
    // In a real implementation, you would need to:
    // 1. Get Metal textures from OBS gs_texture_t objects
    // 2. Execute the Metal compute shader
    // 3. Return the processed texture
    
    // This is a placeholder that returns the original input
    // A full implementation would require deeper integration with OBS's Metal backend
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
    .get_properties = fisheye_filter_get_properties,
    .update = fisheye_filter_update,
    .video_render = fisheye_filter_render,
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
