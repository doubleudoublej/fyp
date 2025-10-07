package com.example.demo.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.example.demo.model.MoodLog;

@Mapper
public interface MoodLogMapper {
    MoodLog selectMoodLogById(Long id);
    List<MoodLog> selectMoodLogsByUserId(Long userId);
    int insertMoodLog(MoodLog moodLog);
    int updateMoodLog(MoodLog moodLog);
    int deleteMoodLog(Long id);
}
