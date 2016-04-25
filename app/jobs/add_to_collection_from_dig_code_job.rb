class AddToCollectionFromDigCodeJob < ActiveJob::Base
  queue_as :default

  DIG_CODES = {
    'diggenetics' => 'Genetics Books and Archives',
    'digukmhl' => 'UK Medical Heritage Library',
    'digmhl(nlm)' => 'Medical Heritage Library / National Library of Medicine ',
    'digrecipe' => 'Recipe books',
    'digmoh' => 'Medical Officer of Health reports',
    'digmhl(francis)' => 'Medical Heritage Library / Harvard University, Francis A Countway Library of Medicine',
    'digmhl(cushing)' => 'Medical Heritage Library / Cushing-Whitney Medical Library',
    'dig19th' => '19th century books',
    'digglasgow' => 'University of Glasgow',
    'digaids' => 'AIDS posters',
    'digmhl(columbia)' => 'Medical Heritage Library / Columbia University',
    'digmhl(gerstein)' => 'Medical Heritage Library / University of Toronto, Gerstein Science Information Centre',
    'digucl(ophta)' => 'University College London',
    'digramc' => 'Royal Army Medical Corps archive',
    'diglshtm' => 'London School of Hygiene and Tropical Medicine ',
    'digfilm' => 'Film and video',
    'digarabic' => 'Arabic manuscripts',
    'digasylum' => 'Mental health archives',
    'digrcpe' => 'Royal College of Physicians England',
    'digthomson' => 'John Thomson photographs',
    'digleeds' => 'University of Leeds',
    'digarabicwl' => 'Arabic manuscripts',
    'digRCPE' => 'Royal College of Physicians Edinburgh',
    'digrcs' => 'Royal College of Surgeons',
    'digicon' => 'Art Collection',
    'digkings(1)' => 'Kings College London',
    'digwms' => 'Medieval manuscripts',
    'digucl(neuro)' => 'University College London',
    'digbristol(2)' => 'University of Bristol',
    'digucl(ortho)' => 'University College London',
    'digaudio' => 'Audio',
    'digrr' => 'Reading Room ',
    'digwtrust' => 'Wellcome Trust publications',
    'digrcpl' => 'Royal College of Physicians London',
    'digwellpub' => 'Wellcome Trust publications',
    'digprojectx' => 'Digital Stories',
    'digmhl(lamar)' => 'Medical Heritage Library / University of Massachusetts Medical School, Lamar Soutter Library',
    'digmhl(emory)' => 'Medical Heritage Library / Emory University ',
    'digsexology' => 'Sexology',
    'digmhl(utdent)' => 'Medical Heritage Library / University of Texas',
    'digforensics' => 'Forensics',
    'diglshtm(2)' => 'London School of Hygiene and Tropical Medicine',
    'digkings(2)' => 'Kings College London',
    'digpathways(Collectors)' => 'Digital Stories / The Collectors',
    'digpathways(Mindcraft)' => 'Digital Stories / Mindcraft',
    'digbiomed' => 'Biomedical images',
    'digucl(pharma)' => 'University College London',
    'digucl(child)' => 'University College London',
    'digmhl(brandeis)' => 'Medical Heritage Library / Brandeis University, Robert D. Farber University Archives & Special Collections Department',
    'digtoft' => 'Mary Toft collection',
    'digfugitive' => 'Fugitive sheets',
    'digmhl(illinois)' => 'Medical Heritage Library / University of Illinois at Chicago, Library of the Health Sciences, Special Collections'
  }


  def perform(record)

    local_codes = record.metadata.fetch('759', []).map {|field| field['a'].to_s.strip }

    local_codes.each do |local_code|

      if DIG_CODES[local_code]

        collection = Collection.find_by_dig_code(local_code) ||
          Collection.create!(dig_code: local_code, name: DIG_CODES[local_code], slug: local_code.gsub('dig', ''))

        begin
          record.collections << collection
        rescue ActiveRecord::RecordNotUnique
          # Already added - ignore.
        end

      end

    end


  end
end
