module utils
  using ImageView, Images
  function showplot(p; name="noname")
    if isdefined(Main,:_JLAB_)
      p|>display
    else
      save("$(name).png",p)
      imshow(load("$(name).png"); name=name)
    end
  end
  export showplot
 
  using Markdown
  function tomdcode(fn,lang="julia")
      fc=read(fn,String);
      Markdown.parse("""
  ```$(lang)
  $(fc)
  ```
  """)
  end
  export tomdcode


end # of module
