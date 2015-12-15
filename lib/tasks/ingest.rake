
namespace :ingest do

  desc 'Import MARC records'
  task :records, [:filename] => [:environment] do |task, args|

    Rails.logger.level = 2

    MarcIngester.new(args[:filename], false).ingest!

  end

end