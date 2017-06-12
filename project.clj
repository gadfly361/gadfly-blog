(defproject cryogen "0.1.0"
  :description "Simple static site generator"
  :url "https://github.com/gadfly361/gadfly-blog"
  :license {:name "MIT"}
  :dependencies [[org.clojure/clojure "1.8.0"]
                 [ring/ring-devel "1.6.1"]
                 [compojure "1.6.0"]
                 [ring-server "0.4.0"]
                 [cryogen-markdown "0.1.6"]
                 [cryogen-core "0.1.56"]]
  :plugins [[lein-ring "0.9.7"]]
  :main cryogen.core
  :ring {:init    cryogen.server/init
         :handler cryogen.server/handler})
