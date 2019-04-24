// OpenCV must be loaded first to prevent build conflicts with ObjC headers.
#include <opencv2/opencv.hpp>

#import "LibBridge.h"

#include <lhecker_bachelor/binarize.h>
#include <lhecker_bachelor/distance.h>
#include <lhecker_bachelor/image.h>
#include <lhecker_bachelor/path.h>
#include <lhecker_bachelor/skeleton.h>
#include <lhecker_bachelor/tracer.h>

static const NSErrorDomain kErrorDomain = @"io.hecker.bachelor";

@implementation LibBridge

+ (void)initialize {
    lhecker_bachelor::tracer::set_level(lhecker_bachelor::tracer::level::timings);
    lhecker_bachelor::tracer::set_log_handler([](const auto& entry) {
        @autoreleasepool {
            auto title = [[NSString alloc] initWithBytes:entry.title.data() length:entry.title.size() encoding:NSASCIIStringEncoding];
            NSLog(@"TRACE %@: %.6fms", title, entry.millis);
        }
    });
}

+ (NSString*)vectorize:(CGContextRef)ctx error:(NSError**)error {
    try {
        lhecker_bachelor::tracer trace{"main"};

        cv::Mat distance;
        cv::Mat skeleton;
        {
            cv::UMat binary;

            {
                cv::Mat input(
                    int(CGBitmapContextGetHeight(ctx)),
                    int(CGBitmapContextGetWidth(ctx)),
                    CV_8UC1,
                    CGBitmapContextGetData(ctx),
                    CGBitmapContextGetBytesPerRow(ctx)
                );
                lhecker_bachelor::image::downscale(input, binary, 1920, 2880);
            }

            lhecker_bachelor::binarize::sauvola(binary, binary, 41, 0.3, cv::THRESH_BINARY_INV);
            lhecker_bachelor::distance::transform(binary, distance);
            lhecker_bachelor::skeleton::zhangsuen(binary, skeleton);
        }

        auto paths = lhecker_bachelor::path::set::search(skeleton, distance);
        paths.apply_approximation(2);

        auto svg = paths.generate_svg(skeleton.size());
        return [[NSString alloc] initWithBytes:svg.data() length:svg.size() encoding:NSASCIIStringEncoding];
    } catch (const std::exception& e) {
        if (error) {
            auto description = [NSString stringWithCString:e.what() encoding:NSUTF8StringEncoding];
            auto userInfo = @{NSLocalizedDescriptionKey: description};
            *error = [NSError errorWithDomain:kErrorDomain code:0 userInfo:userInfo];
        }
    } catch (...) {
        if (error) {
            auto userInfo = @{NSLocalizedDescriptionKey: @"unknown exception"};
            *error = [NSError errorWithDomain:kErrorDomain code:0 userInfo:userInfo];
        }
    }

    return nil;
}

@end
