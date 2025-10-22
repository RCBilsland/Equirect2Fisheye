// Simplified OBS Metal Fisheye Filter Plugin
// This is a basic implementation for local testing

#include <obs-module.h>
#include <CoreFoundation/CoreFoundation.h>
#include <Metal/Metal.h>
#include <string>

// Plugin data structure
typedef struct {
    obs_source_t *context;
    float fov_degrees;
    float pan_degrees;
    float tilt_degrees;
    float yaw_degrees;
    float alpha_level;
} fisheye_filter_data_t;

// Plugin functions
const char *fisheye_filter_get_name(void *unused) {
    return "Metal Fisheye Filter";
}

void fisheye_filter_defaults(obs_data_t *settings) {
    obs_data_set_default_double(settings, "fov_degrees", 180.0);
    obs_data_set_default_double(settings, "pan_degrees", 0.0);
    obs_data_set_default_double(settings, "tilt_degrees", 0.0);
    obs_data_set_default_double(settings, "yaw_degrees", 0.0);
    obs_data_set_default_double(settings, "alpha_level", 0.0);
}

void fisheye_filter_update(void *vdata, obs_data_t *settings) {
    fisheye_filter_data_t *data = (fisheye_filter_data_t *)vdata;
    
    data->fov_degrees = (float)obs_data_get_double(settings, "fov_degrees");
    data->pan_degrees = (float)obs_data_get_double(settings, "pan_degrees");
    data->tilt_degrees = (float)obs_data_get_double(settings, "tilt_degrees");
    data->yaw_degrees = (float)obs_data_get_double(settings, "yaw_degrees");
    data->alpha_level = (float)obs_data_get_double(settings, "alpha_level");
}

obs_properties_t *fisheye_filter_get_properties(void *vdata) {
    UNUSED_PARAMETER(vdata);
    
    obs_properties_t *props = obs_properties_create();
    
    obs_properties_add_float_slider(props, "fov_degrees", "FOV", 0.0, 360.0, 1.0);
    obs_properties_add_float_slider(props, "pan_degrees", "Pan", -180.0, 180.0, 1.0);
    obs_properties_add_float_slider(props, "tilt_degrees", "Tilt", -180.0, 180.0, 1.0);
    obs_properties_add_float_slider(props, "yaw_degrees", "Yaw", -180.0, 180.0, 1.0);
    obs_properties_add_float_slider(props, "alpha_level", "Alpha", 0.0, 1.0, 0.01);
    
    return props;
}

void *fisheye_filter_create(obs_data_t *settings, obs_source_t *context) {
    fisheye_filter_data_t *data = bzalloc(sizeof(*data));
    data->context = context;
    fisheye_filter_update(data, settings);
    return data;
}

void fisheye_filter_destroy(void *vdata) {
    fisheye_filter_data_t *data = (fisheye_filter_data_t *)vdata;
    bfree(data);
}

obs_source_t *fisheye_filter_render(void *vdata, gs_effect_t *effect) {
    UNUSED_PARAMETER(effect);
    
    fisheye_filter_data_t *data = (fisheye_filter_data_t *)vdata;
    obs_source_t *input = obs_filter_get_target(data->context);

    if (!input) {
        return NULL;
    }

    // For now, just pass through the input
    // In a full implementation, this would apply the Metal shader transformation
    obs_source_inc_showing(input);
    return input;
}

// Plugin info
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

// Module setup
OBS_DECLARE_MODULE()
OBS_MODULE_AUTHOR("OBS Metal Fisheye Filter")
OBS_MODULE_DESCRIPTION("Equirectangular to Fisheye Projection using Metal")
OBS_MODULE_EXPORT bool obs_module_load(void) {
    obs_register_source(&fisheye_filter_info);
    return true;
}
