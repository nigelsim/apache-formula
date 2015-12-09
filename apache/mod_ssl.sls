{% from "apache/map.jinja" import apache with context %}

include:
  - apache

{% if apache.get('mod_ssl') %}
mod_ssl:
  pkg.installed:
    - name: {{ apache.mod_ssl }}
    - require:
      - pkg: apache
    - watch_in:
      - module: apache-restart
{% endif %}

{% if grains.get('os_family') == 'Debian' %}
a2enmod mod_ssl:
  cmd.run:
    - name: a2enmod ssl
    - unless: ls /etc/apache2/mods-enabled/ssl.load
    - order: 225
    - require:
      - pkg: apache
    - watch_in:
      - module: apache-restart

{% endif %}
