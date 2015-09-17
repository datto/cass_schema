module CassSchema
  class StatementLoader
    class << self
      def statements(*path_parts)
        file_path = File.join(path_parts)
        file = File.open(file_path).read

        # Parse the individual CQL statements as a list from the file. To do so:
        # - assume statements are separated by two new lines
        # - strip comments and empty lines from each statement
        # - remove statements that are empty
        statements = file.split(/\n{2,}/).map do |statement|
          statement
            .split(/\n/)
            .select { |l| l !~ /^\s*#/ }
            .select { |l| l !~ /^\s*$/ }
            .join("\n")
        end

        statements.select { |s| s.length > 0 }
      end
    end
  end
end
