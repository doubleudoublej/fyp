package com.example.demo.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.demo.mapper.MoodLogMapper;
import com.example.demo.model.MoodLog;

@Service
public class MoodLogService {
    @Autowired
    private MoodLogMapper moodLogMapper;

    public MoodLog getMoodLogById(Long id) {
        return moodLogMapper.selectMoodLogById(id);
    }

    public List<MoodLog> getMoodLogsByUserId(Long userId) {
        return moodLogMapper.selectMoodLogsByUserId(userId);
    }

    public int createMoodLog(MoodLog moodLog) {
        return moodLogMapper.insertMoodLog(moodLog);
    }

    public int updateMoodLog(MoodLog moodLog) {
        return moodLogMapper.updateMoodLog(moodLog);
    }

    public int deleteMoodLog(Long id) {
        return moodLogMapper.deleteMoodLog(id);
    }
}
