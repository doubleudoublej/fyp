package com.example.demo.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.demo.mapper.ActivityMapper;
import com.example.demo.model.Activity;

@Service
public class ActivityService {
    @Autowired
    private ActivityMapper activityMapper;

    public Activity getActivityById(Long id) {
        return activityMapper.selectActivityById(id);
    }

    public List<Activity> getActivitiesByUserId(Long userId) {
        return activityMapper.selectActivitiesByUserId(userId);
    }

    public int createActivity(Activity activity) {
        return activityMapper.insertActivity(activity);
    }

    public int updateActivity(Activity activity) {
        return activityMapper.updateActivity(activity);
    }

    public int deleteActivity(Long id) {
        return activityMapper.deleteActivity(id);
    }
}
