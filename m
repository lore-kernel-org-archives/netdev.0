From: Divy Le Ray <None@chelsio.com>
Subject: [PATCH 9/10] cxgb3 - Add <linux/mutex.h>
Date: Tue, 30 Jan 2007 19:44:29 -0800
Message-ID: <20070131034429.8662.70355.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932811AbXAaDqD@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Include <linux/mutex.h> in adapter.h

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/adapter.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/cxgb3/adapter.h b/drivers/net/cxgb3/adapter.h
index 8902007..97e35c8 100644
--- a/drivers/net/cxgb3/adapter.h
+++ b/drivers/net/cxgb3/adapter.h
@@ -19,6 +19,7 @@
 #include <linux/interrupt.h>
 #include <linux/timer.h>
 #include <linux/cache.h>
+#include <linux/mutex.h>
 #include "t3cdev.h"
 #include <asm/semaphore.h>
 #include <asm/bitops.h>
