From: maximilian attems <janitor@sternwelten.at>
Subject: [patch-kj] remove old ifdef'd code from hamradio/dmascc.c
Date: Mon, 21 Jun 2004 21:42:40 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040621194240.GF1545@sputnik.stro.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 From: Domen Puncer <domen@coderock.org>
 remove unused #include <linux/version.h>

 didn't find maintainer of hamradio, hope it will get picked up.
 Signed-off-by: Maximilian Attems <janitor@sternwelten.at>


---

 linux-2.6.7-max/drivers/net/hamradio/dmascc.c |    1 -
 1 files changed, 1 deletion(-)

diff -puN drivers/net/hamradio/dmascc.c~remove-old-ifdefs-dmascc drivers/net/hamradio/dmascc.c
--- linux-2.6.7/drivers/net/hamradio/dmascc.c~remove-old-ifdefs-dmascc	2004-06-18 09:14:59.000000000 +0200
+++ linux-2.6.7-max/drivers/net/hamradio/dmascc.c	2004-06-18 09:14:59.000000000 +0200
@@ -37,7 +37,6 @@
 #include <linux/rtnetlink.h>
 #include <linux/sockios.h>
 #include <linux/workqueue.h>
-#include <linux/version.h>
 #include <asm/atomic.h>
 #include <asm/bitops.h>
 #include <asm/dma.h>

_
