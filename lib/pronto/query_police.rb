require 'pronto'
require 'shellwords'

module Pronto
  class QueryPolice < Runner
    REPORT_NAME = "qp-report.json"
    DIRTY_WORDS = ['shit', 'piss', 'fuck', 'cunt', 'cocksucker', 'motherfucker', 'tits']

    def run
      return [] if !@patches || @patches.count.zero?

      @patches
        .select { |patch| patch.additions > 0 }
        .map { |patch| inspect(patch) }
        .flatten.compact
    end

    private

    def git_repo_path
      @git_repo_path ||= Rugged::Repository.discover(File.expand_path(Dir.pwd)).workdir
    end

    def inspect(patch)
      offending_lines(patch).map do |offence|
        patch
          .added_lines
          .select { |line| line.new_lineno == offence.dig(:line_number) }
          .map { |line| new_message("Query with debt - #{offence.dig(:debt)} detected", line) }
      end
    end

    def new_message(offence, line)
      path = line.patch.delta.new_file[:path]
      level = :warning

      Message.new(path, line, level, offence, nil, self.class)
    end

    def offending_lines(patch)
      offenses = []

      Dir.chdir(git_repo_path) do
        escaped_file_path = Shellwords.escape(patch.new_file_full_path.to_s)

        File.foreach(escaped_file_path).with_index do |line, line_num|
          bad_query_reports.each do |report|
            offenses << report if report[:line_number] == line_num  && escaped_file_path.include?(report[:file])
          end
        end

        offenses
      end
    end

    def bad_query_reports
      return @report unless @report.nil?

      path = File.join(git_repo_path, REPORT_NAME)
      report = JSON.parse(File.read(path))

      @report = report.keys.map do |file_key|
        file, line_number, action = file_key.split(':')
        {
          debt: report[file_key]['debt'],
          query: report[file_key]['query'],
          analysis: report[file_key]['analysis'],
          file: file,
          line_number: line_number.to_i
        }
      end
    end
  end
end
