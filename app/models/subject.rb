class Subject < ActiveRecord::Base



  def copy_mesh_identifier!
    if identifier
      identifiers['mesh'] ||= identifier
      save!
    end
  end

end
