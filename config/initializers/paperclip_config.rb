# Use the escaped_filename for all attachments
Paperclip::Attachment.default_options.merge!(
  :path => ":rails_root/public/system/:attachment/:id/:style/:escaped_filename",
  :url =>  "/system/:attachment/:id/:style/:escaped_filename")


# ensure that escaped_filename for all attachments is actually escaped
Paperclip.interpolates('escaped_filename') do |attachment, style|

  s = basename(attachment, style)

  # Remove apostrophes so isn't changes to isnt
  s.gsub!(/'/, '')

  # Replace any non-letter or non-number character with a space
  s.gsub!(/[^A-Za-z0-9]+/, ' ')

  # Remove spaces from beginning and end of string
  s.strip!

  # Replace groups of spaces with single hyphen
  s.gsub!(/\ +/, '-')

  return s + "." + extension(attachment, style)

end