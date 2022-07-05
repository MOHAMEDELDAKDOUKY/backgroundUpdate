#include "BackgroundUpdateImpl.hpp"

#include <google/protobuf/util/json_util.h>

#include <algorithm>
#include <iostream>

#include "event.pb.h"
#include "nvdspreprocess_meta.h"


#define PRIMARY_DETECTOR_UID 1
#define PGIE_CLASS_ID_PERSON 0

#define MAX_DISPLAY_LEN 64

void BackgroundUpdateImpl::onCreate(const avid::proto::configuration_values::FieldGroupValue &plugin_config)
{
  // create vpi wrapper instance
  // m_p_vpi_wrapper = std::make_unique<avidVpiWrapper>();

  google::protobuf::util::JsonOptions json_op;
  json_op.add_whitespace = true;
  json_op.preserve_proto_field_names = true;
  json_op.always_print_primitive_fields = true;
  std::string json_str;
  google::protobuf::util::MessageToJsonString(plugin_config, &json_str, json_op);
  //printf("received plugin config: %s\n", json_str.c_str());

  total_number_of_persons = 0;
}

void BackgroundUpdateImpl::onDestroy() {}

void BackgroundUpdateImpl::onFrame(NvBufSurface *p_surface, NvDsFrameMeta *p_frame_meta)
{
  static bool once = true;
  // if (!once) return;
  if (once)
    once = false;

  std::cout << std::endl;

  bool frame_has_obj = false;

  // median_filter_wrapper(input, output_gpu);
  //  std::cout << output_gpu.size();
  //  cv::imwrite("gpu_median_result.png", output_gpu);

  NvDsObjectMeta *obj_meta = NULL;

  guint person_count = 0;

  NvDsMetaList *l_obj = NULL;

  NvBufSurface *dst_buf = NULL;
  NvBufSurface *rec_buf = NULL;

  int offset = 0;
  uint32_t obj_top = 0;
  uint32_t obj_left = 0;
  uint32_t obj_width = 100;
  uint32_t obj_height = 50;

  NvDsDisplayMeta *display_meta = nvds_acquire_display_meta_from_pool(p_frame_meta->base_meta.batch_meta);
  display_meta->num_rects = 1;
  display_meta->rect_params[0].left = obj_left;
  display_meta->rect_params[0].top = obj_top;
  display_meta->rect_params[0].width = obj_width;
  display_meta->rect_params[0].height = obj_height;
  display_meta->rect_params[0].border_width = 2;
  display_meta->rect_params[0].border_color = {0, 1, 0, 1};
  nvds_add_display_meta_to_frame(p_frame_meta, display_meta);

  rec_buf = allocate_surface(p_surface);
  
  if (frame_number%32 == 0) record.push_back(rec_buf);
  
  const int RECORD_LENGTH = 128;
   
  if (frame_number == 1024*4-1)
  {
    dst_buf = allocate_surface(p_surface);
    printf(" main: output_rows: %d output_cols: %d dst_pitch: %d src_pitch: %d \n ",
      dst_buf->surfaceList->height,dst_buf->surfaceList->width, dst_buf->surfaceList->pitch,p_surface->surfaceList->pitch );

    #include <time.h>
    clock_t tStart = clock();

    median_filter(p_surface, dst_buf, record);   
    
    printf("\n\n\nTime taken: %.2fs\n\n\n", (double)(clock() - tStart)/CLOCKS_PER_SEC);

    save_to_disk(dst_buf);

    for (auto rec : record)
    {
      NvBufSurfaceDestroy(rec);
    }
    NvBufSurfaceDestroy(dst_buf);  
    std::cout << "freed once" << std::endl; 

  throw std::runtime_error (" "); 
  }


  // for (l_obj = p_frame_meta->obj_meta_list; l_obj != NULL; l_obj = l_obj->next) {
  //   obj_meta = (NvDsObjectMeta *)(l_obj->data);

  //   unuique_object_ids.insert(obj_meta->object_id);

  //   /* Check that the object has been detected by the primary detector
  //    * and that the class id is that of vehicles/persons. */
  //   if (obj_meta->unique_component_id == PRIMARY_DETECTOR_UID) {
  //     if (obj_meta->class_id == PGIE_CLASS_ID_PERSON) person_count++;
  //     total_number_of_persons++;

  //     sec_buf = saveSurfaceToDisk(p_surface);
  //     NvOSD_TextParams *txt_params = &(obj_meta->text_params);

  //     txt_params->display_text = (char *)g_malloc0(MAX_DISPLAY_LEN);
  //     offset = snprintf(txt_params->display_text, MAX_DISPLAY_LEN, "Person = %d ", person_count);
  //     offset +=
  //         snprintf(txt_params->display_text + offset, MAX_DISPLAY_LEN, "total = %d ", (int)unuique_object_ids.size());

  //     /* Now set the offsets where the string should appear */
  //     txt_params->x_offset = 10;
  //     txt_params->y_offset = 12;

  //     /* Font , font-color and font-size */
  //     txt_params->font_params.font_name = (char *)"Serif";
  //     txt_params->font_params.font_size = 10;
  //     txt_params->font_params.font_color.red = 1.0;
  //     txt_params->font_params.font_color.green = 1.0;
  //     txt_params->font_params.font_color.blue = 1.0;
  //     txt_params->font_params.font_color.alpha = 1.0;

  //     /* Text background color */
  //     txt_params->set_bg_clr = 1;
  //     txt_params->text_bg_clr.red = 0.0;
  //     txt_params->text_bg_clr.green = 0.0;
  //     txt_params->text_bg_clr.blue = 0.0;
  //     txt_params->text_bg_clr.alpha = 1.0;
  //   }
  // }
  // std::cout << "person_count:  " << person_count << std::endl;

  g_print("Frame Number = %d Person Count = %d \n", frame_number, person_count);

  frame_number++;
  std::cout << std::endl;
}

void BackgroundUpdateImpl::onConfig(const avid::proto::configuration_values::FieldGroupValue &plugin_config) {}
