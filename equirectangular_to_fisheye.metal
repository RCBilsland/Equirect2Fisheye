// --------------------------------------------------------------------------
// equirectangular_to_fisheye.metal
// --------------------------------------------------------------------------

#include <metal_stdlib>
using namespace metal;

// Structure to hold constant parameters passed from the CPU (OBS plugin)
struct Uniforms {
    float fov_radians;    // The Field of View for the fisheye (e.g., PI for 180 degrees)
    float aspect_ratio;   // Output aspect ratio (usually 1.0 for a square fisheye)
    float time;           // A simple time counter for animation/effects
    float center_x;       // Horizontal center for the projection (normalized 0.0 to 1.0)
    float center_y;       // Vertical center for the projection (normalized 0.0 to 1.0)

    // NEW ROTATION PARAMETERS
    float pan_radians;    // Rotation around Y
    float tilt_radians;   // Rotation around X
    float yaw_radians;    // Rotation around Z
    
    // NEW ALPHA PARAMETER
    float alpha_level;    // Alpha for outside circle
};

// Function to apply 3D rotation (Roll-Pitch-Yaw equivalent)
float3 rotate(float3 p, float pan, float tilt, float yaw) {
    // 1. Yaw (Rotation around Z) - Applied first
    float cz = cos(yaw);
    float sz = sin(yaw);
    p = float3(p.x * cz - p.y * sz, p.x * sz + p.y * cz, p.z);
    
    // 2. Tilt (Rotation around X) - Applied second
    float cx = cos(tilt);
    float sx = sin(tilt);
    p = float3(p.x, p.y * cx - p.z * sx, p.y * sx + p.z * cx);

    // 3. Pan (Rotation around Y) - Applied last
    float cy = cos(pan);
    float sy = sin(pan);
    p = float3(p.x * cy + p.z * sy, p.y, p.z * cy - p.x * sy);

    return p;
}

// The Metal Compute Kernel
kernel void equirectToFisheye(
    texture2d<float, access::sample> equirect_tex [[texture(0)]],
    texture2d<float, access::write> fisheye_tex [[texture(1)]],
    const constant Uniforms& uniforms [[buffer(0)]],
    uint2 gid [[thread_position_in_grid]])
{
    // 1. Get output pixel coordinates and normalize
    uint width = fisheye_tex.get_width();
    uint height = fisheye_tex.get_height();

    // Check bounds
    if (gid.x >= width || gid.y >= height) {
        return;
    }

    // Normalized coordinates from -1.0 to 1.0, centered at (0, 0)
    float2 normalized_coord = float2(
        (float(gid.x) / float(width) * 2.0 - 1.0) * uniforms.aspect_ratio,
        (float(gid.y) / float(height) * 2.0 - 1.0)
    );

    // Shift the origin if a custom center is provided (advanced)
    normalized_coord.x -= (uniforms.center_x * 2.0 - 1.0);
    normalized_coord.y -= (uniforms.center_y * 2.0 - 1.0);

    // 2. Fisheye to Spherical Coordinates (Inverse Mapping)
    float r = length(normalized_coord);
    float theta = atan2(normalized_coord.y, normalized_coord.x); // Azimuth

    // Check if the pixel is outside the fisheye circle
    if (r > 1.0) {
        // Output black/transparent outside the circle
        fisheye_tex.write(float4(0.0, 0.0, 0.0, uniforms.alpha_level), gid);
        return;
    }

    // Convert radial distance to polar angle (Equidistant Fisheye Model)
    // alpha is the polar angle (angle from the optical axis)
    float alpha = r * uniforms.fov_radians * 0.5;

    // Convert polar angle and azimuth to 3D Cartesian coordinates
    float3 P;
    float sin_alpha = sin(alpha);
    float cos_alpha = cos(alpha);
    P.x = sin_alpha * cos(theta);
    P.y = sin_alpha * sin(theta);
    P.z = cos_alpha;
    
    // 3. APPLY ROTATION (Pan/Tilt/Yaw)
    P = rotate(P, uniforms.pan_radians, uniforms.tilt_radians, uniforms.yaw_radians);

    // 4. Spherical to Equirectangular UV coordinates (using the rotated vector P)
    float latitude = asin(P.y / length(P));
    float longitude = atan2(P.x, P.z);
    // Convert longitude and latitude to normalized equirectangular UV coordinates [0, 1]
    float u_e = (longitude / (2.0 * M_PI_F)) + 0.5;
    float v_e = (latitude / M_PI_F) + 0.5; // (Simplified v-mapping - often uses 1.0 - (lat/pi + 0.5))

    // Correct v_e based on standard Equirectangular to Spherical mapping
    // Equirectangular V should map 0 to PI/2 (North Pole) and 1 to -PI/2 (South Pole)
    v_e = 1.0 - (latitude / M_PI_F + 0.5);

    // 5. Sample the input texture
    constexpr sampler s(address::repeat, filter::linear); // Use linear filtering for smoothness
    float4 color = equirect_tex.sample(s, float2(u_e, v_e));

    // 6. Write the final color to the output texture
    fisheye_tex.write(color, gid);
}
