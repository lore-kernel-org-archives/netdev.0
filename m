From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] janitor: remove unneeded includes (skfp)
Date: Wed, 17 Sep 2003 15:31:29 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030917153129.355860eb.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,
Please apply to 2.6.0-test5-current.

--
~Randy


From: Randy Hron <rwhron@earthlink.net>

diff -Nur linux-2.6.0-test3-bk8/drivers/net/skfp/h/targetos.h linux/drivers/net/skfp/h/targetos.h


 linux-260-test5-kj-rddunlap/drivers/net/skfp/h/targetos.h |    1 -
 1 files changed, 1 deletion(-)

diff -puN drivers/net/skfp/h/targetos.h~version_skfp drivers/net/skfp/h/targetos.h
--- linux-260-test5-kj/drivers/net/skfp/h/targetos.h~version_skfp	2003-09-10 17:09:20.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/skfp/h/targetos.h	2003-09-10 17:09:20.000000000 -0700
@@ -43,7 +43,6 @@
 
 #undef ADDR
 
-#include <linux/version.h>
 #include <asm/io.h>
 #include <linux/netdevice.h>
 #include <linux/fddidevice.h>

_
