require 'nokogiri' # html parsing gem
require 'open-uri' # uri opening gem
require 'uri' # uri parsing gem

def get_image_url(offset)

  # Open the APOD Archive page
  archive_doc = Nokogiri::HTML(open('http://apod.nasa.gov/apod/archivepix.html'))

  # Log the offset if you want to pickup where you left off
  offset_string = offset.to_s
  puts 'Last offset called is ' + offset_string

  # Increment the offset for getting the next link
  offset = offset + 2

  # Get the image url and call the download function
  image_id = archive_doc.css('b a:nth-child('+offset_string+')')[0]["href"]

  download_apod_image('http://apod.nasa.gov/apod/' + image_id, offset)
end

def download_apod_image(url, offset)

  # Open the URL of the image
  doc = Nokogiri::HTML(open(url))

  # Get the link from NASA's terrible HTML, if it can't find anything,
  # just go to the next link
  begin
    image_link = doc.css('center > p:nth-child(3) > a')[0]["href"]
  rescue
    puts 'Load failed, trying next link'
    get_image_url(offset)
  end

  puts 'Image Link is http://apod.nasa.gov/apod/' + image_link

  # Get the image's real name
  file_name = URI.parse(image_link)
  file_name = File.basename(file_name.path)

  # Open and download the image
  File.open( 'images/' + file_name, 'wb') do |fo|
    fo.write open('http://apod.nasa.gov/apod/' + image_link).read

    # Convert the image size to megabytes
    file_size = fo.stat.size.to_f / 2**20
    file_size = file_size.round(2)
    file_size = file_size.to_s
    puts 'Downloaded image '+ file_name +' (' + file_size + 'mb)'
  end

  # Back to the top!
  get_image_url(offset)

end

# Kickoff the whole process, change the offset if
# starting from where you left off, (1361, in my case)
get_image_url(3)
