From: Andrea Gelmini <andrea.gelmini@gelma.net>
Subject: [PATCH 054/199] Documentation/isdn/README.act2000: Checkpatch cleanup
Date: Sun, 23 May 2010 21:50:18 +0200
Message-ID: <1274644226-23612-4-git-send-email-andrea.gelmini@gelma.net>
References: <1274644226-23612-1-git-send-email-andrea.gelmini@gelma.net>
Cc: Karsten Keil <isdn@linux-pingi.de>,
	Randy Dunlap <rdunlap@xenotime.net>, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org
To: andrea.gelmini@gelma.net
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1274644226-23612-1-git-send-email-andrea.gelmini@gelma.net>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Documentation/isdn/README.act2000:19: ERROR: trailing whitespace
Documentation/isdn/README.act2000:20: ERROR: trailing whitespace
Documentation/isdn/README.act2000:21: ERROR: trailing whitespace
Documentation/isdn/README.act2000:22: ERROR: trailing whitespace
Documentation/isdn/README.act2000:23: ERROR: trailing whitespace
Documentation/isdn/README.act2000:24: ERROR: trailing whitespace
Documentation/isdn/README.act2000:26: ERROR: trailing whitespace
Documentation/isdn/README.act2000:27: ERROR: trailing whitespace
Documentation/isdn/README.act2000:28: ERROR: trailing whitespace
Documentation/isdn/README.act2000:29: ERROR: trailing whitespace
Documentation/isdn/README.act2000:30: ERROR: trailing whitespace
Documentation/isdn/README.act2000:31: ERROR: trailing whitespace
Documentation/isdn/README.act2000:32: ERROR: trailing whitespace
Documentation/isdn/README.act2000:64: ERROR: trailing whitespace

Signed-off-by: Andrea Gelmini <andrea.gelmini@gelma.net>
---
 Documentation/isdn/README.act2000 |   28 ++++++++++++++--------------
 1 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/Documentation/isdn/README.act2000 b/Documentation/isdn/README.act2000
index ce7115e..dcc61b2 100644
--- a/Documentation/isdn/README.act2000
+++ b/Documentation/isdn/README.act2000
@@ -16,20 +16,20 @@ Setting up the DIP switches for the IBM Active 2000 ISDN card:
 
      S1  S2  S3  S4  Base-port
      on  on  on  on  0x0200 (Factory default)
-     off on  on  on  0x0240 
-     on  off on  on  0x0280 
-     off off on  on  0x02c0 
-     on  on  off on  0x0300 
-     off on  off on  0x0340 
-     on  off off on  0x0380 
+     off on  on  on  0x0240
+     on  off on  on  0x0280
+     off off on  on  0x02c0
+     on  on  off on  0x0300
+     off on  off on  0x0340
+     on  off off on  0x0380
      on  on  on  off 0xcfe0
-     off on  on  off 0xcfa0 
-     on  off on  off 0xcf60 
-     off off on  off 0xcf20 
-     on  on  off off 0xcee0 
-     off on  off off 0xcea0 
-     on  off off off 0xce60 
-     off off off off Card disabled 
+     off on  on  off 0xcfa0
+     on  off on  off 0xcf60
+     off off on  off 0xcf20
+     on  on  off off 0xcee0
+     off on  off off 0xcea0
+     on  off off off 0xce60
+     off off off off Card disabled
 
 IRQ is configured by software. Possible values are:
 
@@ -61,7 +61,7 @@ Driver built into the kernel:
 
   which means: Autoprobe for an ISA card, use next free IRQ, let the
   ISDN linklevel fill the IdString (usually "line0" for the first card).
- 
+
   If you like to use more than one card, you can use the program
   "actctrl" from the utility-package to configure additional cards.
 
-- 
1.7.1.251.gf80a2

