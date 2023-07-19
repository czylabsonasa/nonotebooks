using Markdown
function tomdcode(fn)
    fc=read(fn,String);
    Markdown.parse("""
```julia
$(fc)
```
""")
end
