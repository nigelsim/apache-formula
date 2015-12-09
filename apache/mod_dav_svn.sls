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
a2enmod dav_svn:
  cmd.run:
    - unless: ls /etc/apache2/mods-enabled/dav_svn.load
    - order: 255
    - require:
      - pkg: apache
      - pkg: mod_dav_svn
    - watch_in:
      - module: apache-restart

a2enmod authz_svn:
  cmd.run:
    - unless: ls /etc/apache2/mods-enabled/authz_svn.load
    - order: 255
    - require:
      - pkg: apache
      - pkg: mod_dav_svn
    - watch_in:
      - module: apache-restart
{% endif %}

