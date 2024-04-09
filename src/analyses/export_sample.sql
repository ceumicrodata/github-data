{% for table in ['contributions', 'users', 'projects'] %}
copy analysis_{{ table }} to '{{ var("output_dir") }}/{{ table }}.csv' (format csv, header true);
{% endfor %}