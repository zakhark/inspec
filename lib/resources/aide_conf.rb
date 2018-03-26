# encoding: utf-8

require 'utils/filter'
require 'utils/parser'
require 'utils/file_reader'

module Inspec::Resources
  class AideConf < Inspec.resource(1)
    name 'aide_conf'
    supports platform: 'unix'
    desc 'Use the aide_conf InSpec audit resource to test the rules established for
      the file integrity tool AIDE. Controlled by the aide.conf file typically at /etc/aide.conf.'
    example "
      describe aide_conf do
        its('selection_lines') { should include '/sbin' }
      end

      describe aide_conf.where { selection_line == '/bin' } do
        its('rules.flatten') { should include 'r' }
      end

      describe aide_conf.all_have_rule('sha512') do
        it { should eq true }
      end
    "

    attr_reader :params

    include CommentParser
    include FileReader

    DEFAULT_UNIX_PATH = '/etc/aide.conf'

    def initialize(aide_conf_path = DEFAULT_UNIX_PATH)
      @content = read_content(aide_conf_path)
    end

    def all_have_rule(rule)
      # Case when file didn't exist or perms didn't allow an open
      # FIXME: test @params > 0? or give this state a name?
      return false if @content.nil?

      has_rule = ->(line) {  line['rules'].include? rule }

      @params.all?(&has_rule)
    end

    FilterTable.create
               .add_accessor(:where)
               .add_accessor(:entries)
               .add(:selection_lines, field: 'selection_line')
               .add(:rules,           field: 'rules')
               .connect(self, :params)

    private

    def read_content(conf_path)
      return @content unless @content.nil?
      @rules = {}

      raw_conf = read_file_content(conf_path)
      @params = parse_conf(raw_conf.lines)
    end

    def parse_conf(content)
      params      = ->(line) { parse_line(line) }
      empty_lines = ->(param) { param['selection_line'].nil? }

      content.reject(&comment?).collect(&params).reject(&empty_lines)
    end

    def comment?
      parse_options = { comment_char: '#', standalone_comments: false }

      ->(data) { parse_comment_line(data, parse_options).first.empty? }
    end

    def parse_line(line)
      line_and_rules = {}
      # Case when line is a rule line
      if line.include?(' = ')
        parse_rule_line(line)
      # Case when line is a selection line
      elsif line.start_with?('/', '!', '=')
        line_and_rules = parse_selection_line(line)
      end
      line_and_rules
    end

    def parse_rule_line(line)
      line.gsub!(/\s+/, '')

      rule_line_arr = line.split('=')
      rule_name     = rule_line_arr.first
      rules_list    = rule_line_arr.last.split('+')

      rules_list.each_index do |i|
        # Cases where rule represents one or more other rules
        rules_list[i] = if @rules.key?(rules_list[i])
                          @rules[rules_list[i]]
                        else
                          handle_multi_rule(rules_list, i)
                        end
      end

      @rules[rule_name] = rules_list.flatten
    end

    def parse_selection_line(line)
      selection_line, selec_line_arr = line.split(' ')

      selection_line.chop! if selection_line.end_with?('/')

      rule_list = selec_line_arr.split('+')

      rule_list.each_index do |i|
        hash_list = @rules[rule_list[i]]

        # Cases where rule represents one or more other rules
        rule_list[i] = if hash_list.nil?
                         handle_multi_rule(rule_list, i)
                       else
                         hash_list
                       end
      end

      rule_list.flatten!

      {
        'selection_line' => selection_line,
        'rules'          => rule_list,
      }
    end

    def handle_multi_rule(rule_list, i)
      # Rules that represent multiple rules (R,L,>)
      r_rules        = %w{p i l n u g s m c md5}
      l_rules        = %w{p i l n u g}
      grow_log_rules = %w{p l u g i n S}

      case rule_list[i]
      when 'R'
        return r_rules
      when 'L'
        return l_rules
      when '>'
        return grow_log_rules
      end

      rule_list[i]
    end
  end
end
