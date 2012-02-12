From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH] [trivial] mISDN: Fix typo in dsp_core.c
Date: Sun, 12 Feb 2012 22:37:06 +0900
Message-ID: <1329053826-1635-1-git-send-email-standby24x7@gmail.com>
Cc: trivial@kernel.org, linux-kernel@vger.kernel.org,
	standby24x7@gmail.com
To: isdn@linux-pingi.de, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Correct spelling "modul" to "module" in
drivers/isdn/mISDN/dsp_core.c

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 drivers/isdn/mISDN/dsp_core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/isdn/mISDN/dsp_core.c b/drivers/isdn/mISDN/dsp_core.c
index 0c41553..742f9f4 100644
--- a/drivers/isdn/mISDN/dsp_core.c
+++ b/drivers/isdn/mISDN/dsp_core.c
@@ -1119,7 +1119,7 @@ static int __init dsp_init(void)
 	int err;
 	int tics;
 
-	printk(KERN_INFO "DSP modul %s\n", mISDN_dsp_revision);
+	printk(KERN_INFO "DSP module %s\n", mISDN_dsp_revision);
 
 	dsp_options = options;
 	dsp_debug = debug;
-- 
1.7.6.5
