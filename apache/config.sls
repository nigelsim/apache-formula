{% from "apache/map.jinja" import apache with context %}

include:
  - apache

{{ apache.configfile }}:
  file.managed:
    - template: jinja
    - source:
      - salt://apache/files/{{ salt['grains.get']('os_family') }}/apache-{{ apache.version }}.config.jinja
    - require:
      - pkg: apache
    - watch_in:
      - service: apache
    - context:
      apache: {{ apache }}

{{ apache.vhostdir }}:
  file.directory:
    - require:
      - pkg: apache
    - watch_in:
      - service: apache

# Add conf files
{% for conf_file, contents in salt['pillar.get']('apache:conf_files_contents', {}).items() %}
{{ apache.confdir }}/{{ conf_file }}:
  file.managed:
    - contents: |
        {{ contents|indent(8) }}
    - user: root
    - group: root
    - watch_in:
      - module: apache-reload
{% endfor %}

{% if grains['os_family']=="Debian" %}
/etc/apache2/envvars:
  file.managed:
    - template: jinja
    - source:
      - salt://apache/files/Debian/envvars.jinja
    - require:
      - pkg: apache
    - watch_in:
      - service: apache
{% endif %}

{% if grains['os_family']=="RedHat" %}
/etc/httpd/conf.d/welcome.conf:
  file.absent:
    - require:
      - pkg: apache
    - watch_in:
      - service: apache
{% endif %}
