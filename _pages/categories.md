---
layout: single
title: Categories
permalink: /categories/
author_profile: true
---

<style>
.categories-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1.5rem;
  margin-top: 2rem;
  max-width: 1200px;
  margin-left: auto;
  margin-right: auto;
}

@media (max-width: 768px) {
  .categories-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 480px) {
  .categories-grid {
    grid-template-columns: 1fr;
  }
}

.category-card {
  position: relative;
  overflow: hidden;
  border-radius: 16px;
  box-shadow: 0 4px 10px rgba(0,0,0,0.15);
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.category-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 20px rgba(0,0,0,0.25);
}

.category-card img {
  width: 100%;
  height: 180px;
  object-fit: cover;
  display: block;
  filter: brightness(70%);
  transition: filter 0.3s ease;
}

.category-card:hover img {
  filter: brightness(55%);
}

.category-name {
  position: absolute;
  bottom: 15px;
  left: 20px;
  color: #fff;
  font-size: 1.25rem;
  font-weight: 700;
  text-shadow: 0 2px 6px rgba(0,0,0,0.5);
}
</style>

<h1>Explore Categories</h1>

<div class="categories-grid">

  <!-- AI Fundamentals Category Card -->
  <a href="/categories/ai-fundamentals" class="category-card">
    <img src="/assets/images/categories/ai-fundamentals.jpg" alt="AI Fundamentals">
    <div class="category-name">AI Fundamentals</div>
  </a>

  <!-- System Design & Scaling Category Card -->
  <a href="/categories/system-design" class="category-card">
    <img src="/assets/images/categories/system-design.jpg" alt="System Design & Scaling">
    <div class="category-name">System Design & Scaling</div>
  </a>

  <!-- LLMOps & MLOps Category Card -->
  <a href="/categories/llmops" class="category-card">
    <img src="/assets/images/categories/llmops.jpg" alt="LLMOps & MLOps">
    <div class="category-name">LLMOps & MLOps</div>
  </a>

  <!-- RAG & Agentic AI Category Card -->
  <a href="/categories/rag-agents" class="category-card">
    <img src="/assets/images/categories/rag.jpg" alt="RAG & Agentic AI">
    <div class="category-name">Retrieval-Augmented Generation</div>
  </a>

  <!-- Real-World Challenges Category Card -->
  <a href="/categories/real-world" class="category-card">
    <img src="/assets/images/categories/real-world.jpg" alt="Real-World Challenges">
    <div class="category-name">Real-World Challenges</div>
  </a>

  <!-- Open Source Category Card -->
  <a href="/categories/open-source" class="category-card">
    <img src="/assets/images/categories/open-source.jpg" alt="Open Source">
    <div class="category-name">Open Source</div>
  </a>

  <!-- Agentic AI Category Card - Updated to fix HTMLProofer validation -->
  <a href="/categories/agentic-ai" class="category-card" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white;">
    <div style="font-size: 4rem; margin: 2rem 0;">🤖</div>
    <div class="category-name" style="color: white;">Agentic AI</div>
  </a>

</div>
