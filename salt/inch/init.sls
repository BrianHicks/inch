include:
  - python
  - supervisor

inch:
  user:
    - present

/opt/apps/inch:
  file.directory:
    - user: inch
    - group: inch
    - require:
      - user: inch

{% if not grains.get('local', False) %}
# TODO: implement checking out the repo
{% endif %}

/opt/apps/inch/env:
  virtualenv.managed:
    - requirements: /opt/apps/inch/inch/requirements.txt
    - user: inch
    - runas: inch
    - require:
      - user: inch
      - file: /opt/apps/inch
      - pkg: python-pkgs

{% from "supervisor/init.sls" import supervisor %}
{% set command="/opt/apps/inch/env/bin/python manage.py runserver 0.0.0.0:8000"
               if grains.get('local', False) else
               "some command!" %}

{{ supervisor("inch-web",
              command=command,
              directory="/opt/apps/inch/inch",
              user="inch",
              require={"user": "inch", "virtualenv": "/opt/apps/inch/env"}) }}
              
