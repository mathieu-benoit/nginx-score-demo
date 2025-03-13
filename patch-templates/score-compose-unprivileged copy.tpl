{{ range $name, $spec := .Workloads }}
{{ range $cname, $_ := $spec.containers }}
- op: set
  path: services.{{ $name }}-{{ $cname }}
  value: |
    read_only: true
    user: 65532
    cap_drop:
      - ALL
{{ end }}
{{ end }}