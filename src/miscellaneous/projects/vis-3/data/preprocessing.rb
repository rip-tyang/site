#!/usr/bin/env ruby -wKU

require 'rexml/document'

class Preprocessing
  FILE_URL = 'Migrant_Data.xml'
  attr_accessor :array

  def initialize
    @array = []
    open FILE_URL do |f|
      doc = REXML::Document.new f
      doc.elements.each '/dataroot/CoastGuardRecord' do |e|
        t = {}
        t[:USCG] = e.elements['USCG_Vessel'].text || "No Data"
        t[:record] = e.elements['RecordType'].text
        t[:vessel] = e.elements['VesselType'].text
        t[:passengers] = e.elements['Passengers'].text.to_i
        t[:death] = e.elements['NumDeaths'].text.to_i
        t[:year], t[:month], t[:day] = e.elements['EncounterDate'].text
          .split('-').map { |entry| entry.to_i }
        t[:destination] = e.elements['EncounterCoords'].text
          .split(',').map { |entry| entry.to_f }
        if e.elements['LaunchCoords'].text then
          t[:departure] = e.elements['LaunchCoords'].text
            .split(',').map { |entry| entry.to_f }
        else
          t[:departure] = [0.0, 0.0]
        end
        if e.elements['RecordNotes'].text then
          t[:names] = e.elements['RecordNotes'].text[22..-1]
            .split(",\n\t\t\t").map { |entry| entry.chomp("\t\t") }
        end
        @array.push t
      end
    end

    @array.sort! do |m,n|
      next m[:year]<=>n[:year] if m[:year] != n[:year]
      next m[:month]<=>n[:month] if m[:month] != n[:month]
      next m[:day]<=>n[:day]
    end
  end
end