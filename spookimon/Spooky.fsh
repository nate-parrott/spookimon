
varying highp vec2 textureCoordinate;

uniform sampler2D inputImageTexture;
uniform highp float spookiness;

highp float rand(highp vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

mediump vec3 rgb2hsv(mediump vec3 c)
{
    mediump vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    mediump vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    mediump vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
    
    highp float d = q.x - min(q.w, q.y);
    highp float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}


mediump vec3 hsv2rgb(mediump vec3 c)
{
    mediump vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    mediump vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main()
{
    highp vec2 point = textureCoordinate + vec2(rand(vec2(0.0, floor(textureCoordinate.y * 10.0))) * 0.015, 0.0) * spookiness;
    lowp vec4 left = texture2D(inputImageTexture, point + vec2(-0.007 * spookiness, 0.0));
    lowp vec4 right = texture2D(inputImageTexture, point + vec2(0.007 * spookiness, 0.0));
    lowp vec4 center = texture2D(inputImageTexture, point);
    lowp vec4 fragmentColor = vec4(left.x, right.y, center.z, center.w);
    
    if (mod(textureCoordinate.y * 250.0, 5.0) < 1.0) {
        fragmentColor += 0.05 * spookiness;
    }
    
    highp float distFromCenter = sqrt(pow(0.5 - point.x, 2.0) + pow(0.5 - point.y, 2.0));
    fragmentColor *= (1.0 - 1.5 * spookiness * (max(0.0, distFromCenter - 0.1)));
    fragmentColor.rg *= (1.0 - spookiness * 0.3);
    
    mediump vec3 hsv = rgb2hsv(fragmentColor.rgb);
    hsv.y = hsv.y * (1.0 - spookiness) + min(hsv.y, 0.8) * spookiness;
    fragmentColor.rgb = hsv2rgb(hsv);
    
    gl_FragColor = fragmentColor;

}
