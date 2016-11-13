(require 'ox-html)

(eval-after-load "ox-html"
  (advice-add 'org-html-src-block :override
	      (lambda (src-block contents info)
		(if (org-export-read-attribute :attr_html src-block :textarea)
		    (org-html--textarea-block src-block)
		  (let ((lang (org-element-property :language src-block))
			(caption (org-export-get-caption src-block))
			(code (org-html-format-code src-block info))
			(label (let ((lbl (and (org-element-property :name src-block)
					       (org-export-get-reference src-block info))))
				 (if lbl (format " id=\"%s\"" lbl) ""))))
		    (if (not lang) (format "<pre><code>class=\"example\"%s>\n%s</code></pre>" label code)
		      (format
		       "<div class=\"org-src-container\">\n%s%s\n</div>"
		       (if (not caption) ""
			 (format "<label class=\"org-src-name\">%s</label>"
				 (org-export-data caption info)))
		       (format "\n<pre><code class=\"hljs %s\"%s>%s</code></pre>" lang label code))))))))


(require 'ox-rss)
(require 'ox-publish)
(setq org-publish-use-timestamps-flag nil)
(setq org-publish-project-alist
      '(("blog"
         :components ("blog-content"
		      "blog-static"
		      "blog-rss"))

        ("blog-content"
         :base-directory "~/gadfly/blog/posts"
         :html-extension "html"
         :base-extension "org"
         :publishing-directory "~/gadfly/blog/publish"
         :publishing-function (org-html-publish-to-html)
         :auto-sitemap t
         :sitemap-filename "posts.org"
         :sitemap-title "Posts"
         :sitemap-sort-files anti-chronologically
         :sitemap-style list
         :makeindex t
         :recursive t
         :section-numbers nil
         :with-toc nil
         :with-latex t
         :html-head-include-default-style nil
         :html-head-include-scripts nil
         :html-head-extra
         "<link rel=\"alternate\" type=\"appliation/rss+xml\"
                href=\"https://gadfly361.github.io/gadfly-blog/rss.xml\"
                title=\"RSS feed for gadfly blog\">
          <link href= \"https://cdnjs.cloudflare.com/ajax/libs/semantic-ui/2.2.4/semantic.min.css\" rel=\"stylesheet\" type=\"text/css\" />
          <link href= \"static/style.css\" rel=\"stylesheet\" type=\"text/css\" />

         <link rel=\"stylesheet\" href=\"static/highlight.css\">


          <title>Gadfly Blog</title>
          <meta http-equiv=\"content-type\" content=\"application/xhtml+xml; charset=UTF-8\" />
          <meta name=\"viewport\" content=\"initial-scale=1,width=device-width,minimum-scale=1\" />"
         :html-preamble
         "<div class=\"ui fluid borderless very compact menu inverted\"
               style=\"border-radius:0;\">

            <div class=\"ui container\">
              <a class=\"item\"
                 href=\"index.html\">
                 <h3 class=\"ui header inverted\"
                     style=\"margin:0;\">
                     gadfly
                     <span style=\"color:green;\"> blog</span></h3>
              </a>

              <div class=\"right menu\">

              <a class=\"item\"
                 href=\"posts.html\">
                 <h3 class=\"ui header inverted\"
                     style=\"margin:0;\">posts</h3>
              </a>

              <a class=\"item\"
                 href=\"https://gadfly361.github.io/gadfly-blog/rss.xml\"
                 target=\"_blank\">
                <i class=\"rss icon inverted large\"></i>
              </a>

              <a class=\"item\"
                 href=\"http://github.com/gadfly361\"
                 target=\"_blank\">
                <i class=\"github icon inverted large\"></i>
              </a>

              <a class=\"item\"
                 href=\"https://twitter.com/gadfly361\"
                 target=\"_blank\">
                <i class=\"twitter icon inverted large\"></i>
              </a>
              </div>
            </div>
          </div>"
         :html-postamble
         (lambda (info)
           "Do not show disqus for Posts and About"
           (cond ((string= (car (plist-get info :title)) "Posts")
		  "<script type=\"text/javascript\">
		  var content = document.getElementById(\"content\")
		  content.className += \"ui text container\"
		  </script>")
                 ((string= (car (plist-get info :title)) "About")
                  "
                  <div class=\"ui text container\">

              <script type=\"text/javascript\">
                 var content = document.getElementById(\"content\")
                 content.className += \"ui text container\"
               </script>")
                 (t
		  "<script type=\"text/javascript\">
		  var content = document.getElementById(\"content\")
		  content.className += \"ui text container\"
		  </script>

         <div class=\"ui text container\">
              <div class=\"ui divider\"></div>

              <div id=\"disqus_thread\"></div>
              <script type=\"text/javascript\">
                (function() { // DON'T EDIT BELOW THIS LINE
                var d = document, s = d.createElement('script');
                s.src = '//gadfly-blog.disqus.com/embed.js';
                s.setAttribute('data-timestamp', +new Date());
                (d.head || d.body).appendChild(s);
                })();
               </script>
               <noscript>Please enable JavaScript to view the
               <a href=\"https://disqus.com/?ref_noscript\">comments powered by Disqus.</a></noscript>

              <script src=\"static/highlight.js\"></script>
              <script>hljs.initHighlightingOnLoad();</script>

         </div>")))
         :exclude "rss.org\\|posts.org\\|theindex.org")

        ("blog-rss"
         :base-directory "~/gadfly/blog/posts"
         :base-extension "org"
         :publishing-directory "~/gadfly/blog/publish"
         :publishing-function (org-rss-publish-to-rss)
         :html-link-home "https://gadfly361.github.io/gadfly-blog/"
         :html-link-use-abs-url t
         :exclude ".*"
         :include ("rss.org")
         :with-toc nil
         :section-numbers nil
         :title "Gadfly Blog")

        ("blog-static"
         :base-directory "~/gadfly/blog/static"
         :base-extension "png\\|jpg\\|css\\|js"
         :publishing-directory "~/gadfly/blog/publish/static"
         :recursive t
         :publishing-function org-publish-attachment)))
