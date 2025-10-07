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

import com.example.demo.model.Article;
import com.example.demo.service.ArticleService;

@RestController
@RequestMapping("/api/articles")
public class ArticleController {
	@Autowired
	private ArticleService articleService;

	@GetMapping("/{id}")
	public Article getArticleById(@PathVariable Long id) {
		return articleService.getArticleById(id);
	}

	@GetMapping
	public List<Article> getAllArticles() {
		return articleService.getAllArticles();
	}

	@PostMapping
	public org.springframework.http.ResponseEntity<com.example.demo.model.Article> createArticle(@RequestBody Article article) {
		Article created = articleService.createArticle(article);
		return org.springframework.http.ResponseEntity.status(org.springframework.http.HttpStatus.CREATED).body(created);
	}

	@PutMapping("/{id}")
	public int updateArticle(@PathVariable Long id, @RequestBody Article article) {
		article.setId(id);
		return articleService.updateArticle(article);
	}

	@DeleteMapping("/{id}")
	public int deleteArticle(@PathVariable Long id) {
		return articleService.deleteArticle(id);
	}
}
