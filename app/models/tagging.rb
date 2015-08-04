class Tagging < ActiveRecord::Base

  belongs_to :subject
  belongs_to :record

end
