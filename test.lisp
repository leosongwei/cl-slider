(slide
  (body
    (reverse (bold "Slider: 用S表达式制作朴实的幻灯片")) (br)
    (brer
      "* slider是一个播放幻灯片用的程序"
      "* slider的DSL基于S表达式"
      "* slider通过Lisp的宏功能生成代码")))

(slide
  :background yellow
  (body (reverse (bold "操作说明")) (br)
        (brer
          (color green "* j: 下一页")
          (color green "* k: 上一页")
          (color red "* R: 重新载入（我还没有调试）")
          (color blue "* q: 退出Slider"))))

(slide :background red
  (body (reverse (bold "Slider是一个花了8小时写成的程序！！")) (br)
        (brer
          "* 不稳定，使用后果自负"
          "* 睡眠不足"
          "* 意识流编程"
          "* 很多bug"
          "* 简陋的代码")))
