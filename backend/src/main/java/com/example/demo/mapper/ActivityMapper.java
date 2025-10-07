package com.example.demo.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.example.demo.model.Activity;

@Mapper
public interface ActivityMapper {
    Activity selectActivityById(Long id);
    List<Activity> selectActivitiesByUserId(Long userId);
    int insertActivity(Activity activity);
    int updateActivity(Activity activity);
    int deleteActivity(Long id);
}
