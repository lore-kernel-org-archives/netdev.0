From: Olivier Sobrie <olivier@sobrie.be>
Subject: [PATCH v2 01/11] hso: remove useless header file timer.h
Date: Fri, 30 Jan 2015 13:21:53 +0100
Message-ID: <1422620523-15021-2-git-send-email-olivier@sobrie.be>
References: <1421756978-4093-1-git-send-email-olivier@sobrie.be>
 <1422620523-15021-1-git-send-email-olivier@sobrie.be>
Cc: linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, Olivier Sobrie <olivier@sobrie.be>
To: Jan Dumon <j.dumon@option.com>, Dan Williams <dcbw@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1422620523-15021-1-git-send-email-olivier@sobrie.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

No timer related function is used in this driver.

Signed-off-by: Olivier Sobrie <olivier@sobrie.be>
---
 drivers/net/usb/hso.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index babda7d..cb0bcc1 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -58,7 +58,6 @@
 #include <linux/module.h>
 #include <linux/ethtool.h>
 #include <linux/usb.h>
-#include <linux/timer.h>
 #include <linux/tty.h>
 #include <linux/tty_driver.h>
 #include <linux/tty_flip.h>
-- 
2.2.0
