require 'yaml'
require 'ostruct'
require 'active_support/inflector'

module Codecom
  class Runner
    attr_accessor :configuration

    def template_options(line)
      {
        author_name: extract_author_name,
        method_name: extract_method_name(line),
        params_name: extract_method_arguments(line)
      }
    end

    def extract_method_arguments(line)
      method = extract_method_name(line)

      if method.include?('(')
        method.scan(/\(([^\)]+)\)/)[0][0].split(',').map(&:strip)
      else
        []
      end
    end

    def extract_author_name
      `git config user.name`.strip
    end

    def extract_git_revision
      path = File.expand_path('../..', File.dirname(__FILE__))
      `git --git-dir #{path}/.git rev-parse --short HEAD`.strip
    end

    def extract_method_name(line)
      line.strip.split('def ')[1]
    end

    def extract_method_name_without_arguments(line)
      name = extract_method_name(line)
      name.include?('(') ? name.split('(')[0] : name.split(' ')[0]
    end

    def process_line(line, index)
      method_name = template_options(line).fetch(:method_name)
      replaced_template = replace_template(template, template_options(line))
      indent_template(replaced_template, line.index('def '))
    end

    def replace_template(data, options = {})
      data = data.gsub('%{method_name}', options.fetch(:method_name))
      data = data.gsub('%{author_name}', options.fetch(:author_name))

      params = options.fetch(:params_name).map do |param|
        param_template.gsub('%{param}', param)
      end

      params = params.any? ? params.join("\n").prepend("#\n") : '# '
      data.gsub('# %{params}', params)
    end

    def param_template
      "# @param %{param} [Class] Write param definition here."
    end

    def indent_template(template, index)
      striped_template(template).map do |slice|
        slice.prepend(' ' * index)
      end.join("\n") + "\n"
    end

    def striped_template(template)
      template.strip.split("\n").map(&:strip)
    end

    def initialize
      process_comments
    end

    def process_comments(source_path = ".", end_with = "*.rb")
      Dir.glob("./#{source_path}/**/#{end_with}").each do |path|
        comments = []
        temp_file = Tempfile.new(SecureRandom.hex)

        begin
          File.open(path).each_with_index do |line, index|
            if line.strip.start_with?('#')
              comments.push(line)
            else
              if line.strip.start_with?('def ')
                method_name = extract_method_name_without_arguments(line)
                data = comments.none? ? process_line(line, index) : comments.join

                temp_file.print(data)
              else
                temp_file.print(comments.join)
              end

              comments = []
              temp_file.write(line)
            end
          end

          temp_file.print(comments.join)
          temp_file.close

          FileUtils.mv(temp_file.path, path)
        ensure
          temp_file.close
          temp_file.unlink
        end
      end
    end

    def template(template_name = 'template.txt')
      File.read([File.dirname(__FILE__), template_name].join('/'))
    end
  end
end
