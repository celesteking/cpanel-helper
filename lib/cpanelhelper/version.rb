module CPanelHelper
  module Version
    MAJOR   = 0
    MINOR   = 4
    RELEASE = 1

    AUTHORS = {
        'Yuri Arabadji' => [2012, 2013, 2014, 2021]
    }

    def self.string
      "#{MAJOR}.#{MINOR}.#{RELEASE}"
    end

    def self.authors
      AUTHORS.collect { |ap| [ap[1]].flatten.join(', ') + ' ' + ap[0] }
    end
  end
end
