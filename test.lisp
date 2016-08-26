(slide
  (body
    (hi (b "Slider: 用S表达式制作朴实的幻灯片!!")) (br)
    (br)
    (brer
      "* Slider是一个播放幻灯片用的程序，现仅支持SBCL"
      "* 依赖于QuickLisp、cl-ncurses、uffi"
      "* Slider的DSL基于S表达式，直接用了Common Lisp的reader"
      "* Slider通过Lisp的宏将DSL转化为渲染代码编译执行")))

(slide
  :background yellow
  (body (hi (b "操作说明")) (br)
   (brer
     (c green "* j: 下一页")
     (c green "* k: 上一页")
     (c red "* R: 重新载入（我还没有调试）")
     (c blue "* q: 退出Slider"))))

(slide :background red
       (body (hi (b "Slider是一个花了不足8小时写成的程序！！")) (br)
        (brer
          "* 不稳定，使用后果自负"
          "* 睡眠不足"
          "* 意识流编程"
          "* 很多bug"
          "* 简陋的代码")))
