SimpleCov.start do
  minimum_coverage 90

  add_filter "debug.sh"
  add_filter "/test/"
  add_filter "/.git/"
end
