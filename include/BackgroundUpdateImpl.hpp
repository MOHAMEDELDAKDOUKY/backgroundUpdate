#pragma once

#include <cstdio>
#include <memory>
#include <set>

#include "avidplugin.hpp"
#include "frame_meta.pb.h"
#include "nvbufsurface.h"
#include "nvbufsurftransform.h"
#include <opencv2/opencv.hpp>
#include "utils.hpp"

#include <vector>

class BackgroundUpdateImpl : public avid::AvidPlugin {
 public:
  void onCreate(const avid::proto::configuration_values::FieldGroupValue &plugin_config);
  void onFrame(NvBufSurface *p_surface, NvDsFrameMeta *p_frame_meta);
  void onConfig(const avid::proto::configuration_values::FieldGroupValue &plugin_config);
  void onDestroy();

  guint total_number_of_persons;
  guint frame_number = 0;

  std::set<int> unuique_object_ids;

  std::vector <NvBufSurface*> record; 
  
};

extern "C" {
avid::AvidPlugin *create_instance() { return new BackgroundUpdateImpl(); }
}

extern "C" {
void median_filter_wrapper(const cv::Mat &input, cv::Mat &output);
}

extern "C" {
void median_filter(NvBufSurface *src, NvBufSurface* dst, std::vector <NvBufSurface*> record);
}


