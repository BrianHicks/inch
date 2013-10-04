supervisor:
  pkg:
    - installed

{# use of False as values for stdout and stderr is a to get sane boolean operation #}
{% macro supervisor(name, command, directory, user, stdout=False, stderr=False, watch={}, require={}) %}
{{ name }}-supervisor:
  file.managed:
    - name: /etc/supervisor/conf.d/{{ name }}.conf
    - source: salt://supervisor/service.conf.jinja2
    - template: jinja
      program_name: {{ name }}
      command: {{ command }}
      directory: {{ directory }}
      user: {{ user }}
      stdout: {{ stdout or "/var/log/supervisor/" + name + "-stdout.log" }}
      stderr: {{ stderr or "/var/log/supervisor/" + name + "-stderr.log" }}
    - require:
      - pkg: supervisor
      {% for type, name in require.items() %}
      - {{ type }}: {{ name }}
      {% endfor %}

  cmd.wait:
    - name: "supervisorctl reread && supervisorctl update {{ name }}"
    - watch:
      - file: {{ name }}-supervisor

  supervisord.running:
    - name: {{ name }}
    - restart: True
    {% if watch %}
    - watch:
    {% for type, name in watch.items() %}
      - {{ type }}: {{ name }}
    {% endfor %}
    {% endif %}
    - require:
      - pkg: supervisor
      {% for type, name in require.items() %}
      - {{ type }}: {{ name }}
      {% endfor %}
{% endmacro %}
