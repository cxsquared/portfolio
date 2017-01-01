class CategoryPostPaginator < Jekyll::Generator
    def generate(site)
        all_posts = site.categories[site.config['paginated_category']]
        site.data['all_posts'] = all_posts
        posts_per_page = Float(site.config['posts_per_page'])
        total_posts = Float(all_posts.size)
        total_pages = Float(total_posts / posts_per_page)
        total_pages = total_pages.ceil
        site.data['paginated_pages'] = Hash.new
        (1..total_pages).each do |page_num|
            site.pages << PostListingPage.new(site, total_pages, page_num, all_posts.slice!(0, posts_per_page.to_i))
        end
    end
end
