From: Geliang Tang <geliangtang@gmail.com>
Subject: [PATCH] net: ieee802154: drop duplicate header delay.h
Date: Thu, 24 Nov 2016 21:58:32 +0800
Message-ID: <f64943b9c1da12b6199ba745ba04cb477a05a5a3.1479991128.git.geliangtang@gmail.com>
References: <15299de49216a2360976ca37ff774cae9d27d88b.1479991297.git.geliangtang@gmail.com>
Cc: Geliang Tang <geliangtang@gmail.com>, linux-wpan@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Michael Hennerich <michael.hennerich@analog.com>,
        Alexander Aring <aar@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <15299de49216a2360976ca37ff774cae9d27d88b.1479991297.git.geliangtang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Drop duplicate header delay.h from adf7242.c.

Signed-off-by: Geliang Tang <geliangtang@gmail.com>
---
 drivers/net/ieee802154/adf7242.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ieee802154/adf7242.c b/drivers/net/ieee802154/adf7242.c
index 4ff4c7d..3e4c8b2 100644
--- a/drivers/net/ieee802154/adf7242.c
+++ b/drivers/net/ieee802154/adf7242.c
@@ -20,7 +20,6 @@
 #include <linux/skbuff.h>
 #include <linux/of.h>
 #include <linux/irq.h>
-#include <linux/delay.h>
 #include <linux/debugfs.h>
 #include <linux/bitops.h>
 #include <linux/ieee802154.h>
-- 
2.9.3
