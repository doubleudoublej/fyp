package com.example.demo.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.example.demo.model.Article;

@Mapper
public interface ArticleMapper {
	Article selectArticleById(Long id);
	List<Article> selectAllArticles();
	int insertArticle(Article article);
	int updateArticle(Article article);
	int deleteArticle(Long id);
}
