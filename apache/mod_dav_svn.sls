{% from "apache/map.jinja" import apache with context %}

include:
  - apache

{% if apache.get('mod_dav_svn') %}
mod_dav_svn:
  pkg.installed:
    - name: {{ apache.mod_dav_svn }}
    - require:
      - pkg: apache
    - watch_in:
      - module: apache-restart
{% endif %}

{% if grains.get('os_family') == 'Debian' %}
a2enmod mod_dav_svn:
  cmd.run:
    - name: a2enmod dav_svn
    - unless: ls /etc/apache2/mods-enabled/dav_svn.load
    - order: 225
    - require:
      - pkg: apache
    - watch_in:
      - module: apache-restart
{% endif %}

