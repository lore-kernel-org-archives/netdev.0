From: Joe Perches <joe@perches.com>
Subject: [PATCH 6/8] lib8390: Convert include <asm to include <linux
Date: Wed, 22 Jun 2011 23:38:58 -0700
Message-ID: <72b65495f39d7667425adc0adc5674a063ef3fb0.1308810463.git.joe@perches.com>
References: <cover.1308810463.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1308810463.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/lib8390.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/lib8390.c b/drivers/net/lib8390.c
index b0ee6f6..946b255 100644
--- a/drivers/net/lib8390.c
+++ b/drivers/net/lib8390.c
@@ -58,8 +58,8 @@
 #include <linux/string.h>
 #include <linux/bitops.h>
 #include <asm/system.h>
-#include <asm/uaccess.h>
-#include <asm/io.h>
+#include <linux/uaccess.h>
+#include <linux/io.h>
 #include <asm/irq.h>
 #include <linux/delay.h>
 #include <linux/errno.h>
-- 
1.7.6.rc3
