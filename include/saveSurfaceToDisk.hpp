#pragma once

#include <google/protobuf/util/json_util.h>

#include <algorithm>
#include <iostream>
#include <opencv2/opencv.hpp>

#include "event.pb.h"
#include "nvbufsurface.h"
#include "nvbufsurftransform.h"

NvBufSurface *saveSurfaceToDisk(NvBufSurface *surface);
