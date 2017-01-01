class PostListingPage < Jekyll::Page
    def initialize(site, total_pages, current_page, current_posts)
        @site = site
        @total_pages = total_pages
        @current_page = current_page
        self.ext = '.html'
        self.basename = 'index'
        prev_page = nil
        next_page = current_page + 1
        if current_page > 1
            prev_page = current_page - 1
        end
        if next_page > total_pages
            next_page = nil
        end
        self.data = {
            'layout' => 'default',
            'title' => "Tutorials",
            'current_posts' => current_posts,
            'total_pages' => total_pages,
            'current_page' => current_page,
            'prev_page' => prev_page,
            'next_page' => next_page
        }
        self.content = <<-EOS
<h1>Tutorials</h1>
<div class="posts">
  {% for post in page.current_posts %}
  <div class="post">
    <h1 class="post-title">
      <a href="{{ site.baseurl }}{{ post.url }}">
        {{ post.title }}
      </a>
    </h1>

    <span class="post-date">{{ post.date | date_to_string }} </span>

    {% if post.image %}
    	<img src="{{ site.baseurl }}/assets/{{ post.image }}">
    {% endif %}

    {{ post.excerpt }}

    <a href="{{ site.baseurl }}{{ post.url }}">Read More</a>
  </div>
  {% endfor %}
</div>
{% if page.total_pages > 1 %}
    <div class="pagination">
        {% if page.next_page %}
            <a class="pagination-item older" href="{{ site.baseurl }}/tutorial/page{{page.next_page}}">Older</a>
        {% else %}
            <span class="pagination-item older">Older</span>
        {% endif %}
        {% if page.prev_page %}
            {% if page.prev_page == 1 %}
                <a class="pagination-item newer" href="{{ site.baseurl }}/tutorial/">Newer</a>
            {% else %}
                 <a class="pagination-item newer" href="{{ site.baseurl }}/tutorial/page{{page.prev_page}}">Newer</a>
            {% endif %}
        {% else %}
            <span class="pagination-item newer">Newer</span>
        {% endif %}
    </div>
{% endif %}
EOS
    end
    def url
        if @current_page == 1
            File.join("/", "tutorial", 'index.html')
        else
            File.join("/", "tutorial", "page" + "#{@current_page}", 'index.html')
        end
    end
    def to_liquid
        Jekyll::Utils.deep_merge_hashes(self.data, {
            "url" => self.url,
            "content" => self.content
        })
    end
    def html?
        true
    end
end


