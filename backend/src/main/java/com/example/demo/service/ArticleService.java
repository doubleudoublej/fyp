package com.example.demo.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.demo.mapper.ArticleMapper;
import com.example.demo.model.Article;

@Service
public class ArticleService {
    @Autowired
    private ArticleMapper articleMapper;

    public Article getArticleById(Long id) {
        return articleMapper.selectArticleById(id);
    }

    public List<Article> getAllArticles() {
        return articleMapper.selectAllArticles();
    }

    public Article createArticle(Article article) {
        articleMapper.insertArticle(article); // will populate id via useGeneratedKeys
        return article;
    }

    public int updateArticle(Article article) {
        return articleMapper.updateArticle(article);
    }

    public int deleteArticle(Long id) {
        return articleMapper.deleteArticle(id);
    }
}
