gem 'actionpack'

module CoHack
  module CalendarHelper
    def calendar_hack(start_date, end_date, options={}, &block)
      calendar = Calendar.new(start_date, end_date, options)
      
      safe_concat(calendar.start_table.html_safe)
      
      safe_concat("<tr>")
      start_index = calendar.start_date.wday - 1

      (0..start_index).each{ |day_index| safe_concat("<td></td>") }
      
      calendar.days.each do |day| 
        safe_concat("<td id ='#{day.to_s.gsub("/", "_")}' class='day'>")
        if block
          yield(day)
        else
          safe_concat(day.to_s)
        end       
        safe_concat("</td>")
        safe_concat("</tr>\n<tr>") if day.wday == 6
      end
      
      safe_concat(calendar.finish_table.html_safe).html_safe
    end
  end
 
  # TODO: Maybe make output prettier?
  class Calendar
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::UrlHelper
    
    attr_accessor :start_date, :end_date, :days
    
    def initialize(start_date, end_date, options={})
      @start_date, @end_date = start_date, end_date
      @options = options.symbolize_keys.reverse_merge(Calendar.default_calendar_options)
 
      @days = @start_date..@end_date
    end
    
    def start_table
      <<-EOF
        <table class="#{@options[:class]}">
          <thead>
            #{show_day_names}
          </thead>
          <tbody class='selectable'>
      EOF
    end
    
    def finish_table
      <<-EOF
          </tbody>
        </table>
      EOF
    end
    
    private
    
    def show_day_names
      #assume sunday-saturday
      return if @options[:hide_day_names]
      
      output = []
      output << '<tr class="day_names">'
      (0..6).each do |day_index|
        day_name = Date::DAYNAMES[day_index]
        output << "<th class='#{day_name.downcase}'>#{day_name}</th>"
      end
      output << "</tr>"
      output.join.html_safe
    end
    
    class << self
      def weekend?(day)
        [0,6].include?(day.wday) # 0 = Sunday, 6 = Saturday
      end

      def default_calendar_options
        {
          :class => "calendar",
          :first_day_of_week => I18n.translate(:'date.first_day_of_week', :default => "0").to_i,
          :hide_day_names => false,
          :hide_month_name => false,
          :use_full_day_names => false
        }
      end
    end
  end
end
ActionView::Base.send(:include, CoHack::CalendarHelper)