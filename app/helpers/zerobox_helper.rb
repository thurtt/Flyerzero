module ZeroboxHelper
  def size_in_pixels( style )
      if style == "small"
	    return "130x163"
      end
      if style == "medium"
	    return "400x500"
      end
      if style == "large"
	    return "600x750"
      end
  end
end
