From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] janitor: e100: cleanup #includes
Date: Thu, 25 Sep 2003 22:18:57 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030925221857.58a61c4b.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, scott.feldman@intel.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,
Please apply to 2.6.0-test5-current.

Thanks,
--
~Randy


From: Randy Hron <rwhron@earthlink.net>


Remove unneeded include of version.h.
Test compiled against 2.6.0-test5-bk9.


 linux-260-t5bk12-kj-rddunlap/drivers/net/e100/e100.h |    1 -
 1 files changed, 1 deletion(-)

diff -puN drivers/net/e100/e100.h~net_e100_includes drivers/net/e100/e100.h
--- linux-260-t5bk12-kj/drivers/net/e100/e100.h~net_e100_includes	2003-09-25 16:26:00.000000000 -0700
+++ linux-260-t5bk12-kj-rddunlap/drivers/net/e100/e100.h	2003-09-25 16:26:00.000000000 -0700
@@ -43,7 +43,6 @@
 #include <linux/timer.h>
 #include <linux/slab.h>
 #include <linux/interrupt.h>
-#include <linux/version.h>
 #include <linux/string.h>
 #include <linux/wait.h>
 #include <linux/reboot.h>

_
