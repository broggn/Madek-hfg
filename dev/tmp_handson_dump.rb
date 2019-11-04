SET_ID = '3ec95285-9efe-434f-82fe-2a5d60bc489a'
PUBLIC_PATH = '/madek/server/webapp/public/assets'
SECRET = File.read('/home/madek/tmp_handson_secret').chomp!
exit(1) unless SECRET.present?

DUMP_DIR = "#{PUBLIC_PATH}/#{SECRET}"
DUMP_FILE = "#{DUMP_DIR}/handson_#{(DateTime.now.to_date - 1.day).iso8601}.json"

dump = Collection
  .find(SET_ID)
  .child_media_resources
  .select { |entry| entry.type == 'MediaEntry' }
  .map do |res|
    entry = MediaEntry.find(res.id)
    mf = entry.media_file
    {
      entry_id: entry.id,
      file_id: mf.id,
      file_original_name: mf.filename,
      media_type: mf.media_type,
      entry_url: "https://medienarchiv.zhdk.ch/entries/#{entry.id}",
      file_url: "https://medienarchiv.zhdk.ch/files/#{mf.id}",
      previews:
        mf.previews.map do |p|
          {
            preview_id: p.id,
            media_type: p.media_type,
            content_type: p.content_type,
            size_class: p.thumbnail,
            preview_url: "https://medienarchiv.zhdk.ch/media/#{p.id}"
          }
        end
    }
  end


FileUtils.mkdir_p(DUMP_DIR)
File.write(DUMP_FILE, dump.to_json)
