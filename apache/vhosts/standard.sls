{% from "apache/map.jinja" import apache with context %}

include:
  - apache

{% for id, site in salt['pillar.get']('apache:sites', {}).items() %}
{% set documentroot = site.get('DocumentRoot', '{0}/{1}'.format(apache.wwwdir, id)) %}

{{ id }}:
  file:
    - managed
    - name: {{ apache.vhostdir }}/{{ id }}{{ apache.confext }}
    - source: {{ site.get('template_file', 'salt://apache/vhosts/standard.tmpl') }}
    - template: {{ site.get('template_engine', 'jinja') }}
    - context:
        id: {{ id|json }}
        site: {{ site|json }}
        map: {{ apache|json }}
    - require:
      - pkg: apache
    - watch_in:
      - module: apache-reload

{% if site.get('DocumentRoot') != False %}
{{ id }}-documentroot:
  file.directory:
    - unless: test -d {{ documentroot }}
    - name: {{ documentroot }}
    - makedirs: True
    - allow_symlink: True
{% endif %}

# Create the certificate files if the contents is provided
{% if site.get('SSLCertificate') and site.get('SSLCertificateFile') %}
{{ site['SSLCertificateFile'] }}:
  file.managed:
    - contents: |-
        {{ site['SSLCertificate']|indent(8) }}
    - user: root
    - group: root
    - watch_in:
      - module: apache-reload
{% endif %}

{% if site.get('SSLCertificateKey') and site.get('SSLCertificateKeyFile') %}
{{ site['SSLCertificateKeyFile'] }}:
  file.managed:
    - contents: |
        {{ site['SSLCertificateKey']|indent(8) }}
    - mode: 600
    - user: root
    - group: root
    - watch_in:
      - module: apache-reload
{% endif %}

{% if site.get('SSLCertificateChain') and site.get('SSLCertificateChainFile') %}
{{ site['SSLCertificateChainFile'] }}:
  file.managed:
    - contents: |
        {{ site['SSLCertificateChain']|indent(8) }}
    - user: root
    - group: root
    - watch_in:
      - module: apache-reload
{% endif %}

{% if grains.os_family == 'Debian' %}
{% if site.get('enabled', True) %}
a2ensite {{ id }}{{ apache.confext }}:
  cmd:
    - run
    - unless: test -f /etc/apache2/sites-enabled/{{ id }}{{ apache.confext }}
    - require:
      - file: /etc/apache2/sites-available/{{ id }}{{ apache.confext }}
    - watch_in:
      - module: apache-reload
{% else %}
a2dissite {{ id }}{{ apache.confext }}:
  cmd:
    - run
    - onlyif: test -f /etc/apache2/sites-enabled/{{ id }}{{ apache.confext }}
    - require:
      - file: /etc/apache2/sites-available/{{ id }}{{ apache.confext }}
    - watch_in:
      - module: apache-reload
{% endif %}
{% endif %}

{% endfor %}
