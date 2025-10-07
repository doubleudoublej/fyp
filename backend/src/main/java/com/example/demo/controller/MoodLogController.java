package com.example.demo.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.demo.model.MoodLog;
import com.example.demo.service.MoodLogService;

@RestController
@RequestMapping("/api/moodlogs")
public class MoodLogController {
    @Autowired
    private MoodLogService moodLogService;

    @GetMapping("/{id}")
    public MoodLog getMoodLogById(@PathVariable Long id) {
        return moodLogService.getMoodLogById(id);
    }

    @GetMapping("/user/{userId}")
    public List<MoodLog> getMoodLogsByUserId(@PathVariable Long userId) {
        return moodLogService.getMoodLogsByUserId(userId);
    }

    @PostMapping
    public int createMoodLog(@RequestBody MoodLog moodLog) {
        return moodLogService.createMoodLog(moodLog);
    }

    @PutMapping("/{id}")
    public int updateMoodLog(@PathVariable Long id, @RequestBody MoodLog moodLog) {
        moodLog.setId(id);
        return moodLogService.updateMoodLog(moodLog);
    }

    @DeleteMapping("/{id}")
    public int deleteMoodLog(@PathVariable Long id) {
        return moodLogService.deleteMoodLog(id);
    }
}
