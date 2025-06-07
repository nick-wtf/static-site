static-site-0.1.0.tgz:
	helm package .

install: static-site-0.1.0.tgz
	helm push static-site-0.1.0.tgz oci://registry.nick.wtf/library
