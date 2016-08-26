(slide
  (body
    (bold "Slider")
    (br)
    (brer
      "* slider是一个播放幻灯片用的程序"
      "* slider有自己的DSL"
      "* slider通过Lisp的宏功能生成代码")))

(slide
  :background yellow
  (body "这一页只有一行"))

(slide :background red
  (body (reverse (bold "Slider是一个花了8小时写成的程序！！")) (br)
        (brer
          "* 不稳定，使用后果自负"
          "* 意识流编程"
          "* 简陋的代码")))
