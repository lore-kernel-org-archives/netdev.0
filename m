From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] janitor: remove unneeded includes (wanrouter)
Date: Wed, 17 Sep 2003 15:13:18 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030917151318.316bfd24.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, ncorbic@sangoma.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,
Please apply to 2.6.0-test5-current.

Thanks.
--
~Randy


From: Randy Hron <rwhron@earthlink.net>

 linux-260-test5-kj-rddunlap/net/wanrouter/af_wanpipe.c |    1 -
 linux-260-test5-kj-rddunlap/net/wanrouter/wanmain.c    |    1 -
 2 files changed, 2 deletions(-)

diff -puN net/wanrouter/af_wanpipe.c~version_net_wanrouter net/wanrouter/af_wanpipe.c
--- linux-260-test5-kj/net/wanrouter/af_wanpipe.c~version_net_wanrouter	2003-09-10 17:08:51.000000000 -0700
+++ linux-260-test5-kj-rddunlap/net/wanrouter/af_wanpipe.c	2003-09-10 17:08:51.000000000 -0700
@@ -32,7 +32,6 @@
 *
 ******************************************************************************/
 
-#include <linux/version.h>
 #include <linux/config.h>
 #include <linux/types.h>
 #include <linux/sched.h>
diff -puN net/wanrouter/wanmain.c~version_net_wanrouter net/wanrouter/wanmain.c
--- linux-260-test5-kj/net/wanrouter/wanmain.c~version_net_wanrouter	2003-09-10 17:08:51.000000000 -0700
+++ linux-260-test5-kj-rddunlap/net/wanrouter/wanmain.c	2003-09-10 17:08:51.000000000 -0700
@@ -42,7 +42,6 @@
 * Jun 02, 1999  Gideon Hack	Updates for Linux 2.0.X and 2.2.X kernels.
 *****************************************************************************/
 
-#include <linux/version.h>
 #include <linux/config.h>
 #include <linux/stddef.h>	/* offsetof(), etc. */
 #include <linux/errno.h>	/* return codes */

_
