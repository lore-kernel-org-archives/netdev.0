From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] sk98lin: planned removal
Date: Wed, 7 Feb 2007 09:18:30 -0800
Message-ID: <20070207091830.59f72f46@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161394AbXBGRSs@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Document planned removal of sk98lin driver.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
---
 Documentation/feature-removal-schedule.txt |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
index 0ba6af0..d08a4af 100644
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -325,3 +325,10 @@ Why:	Unmaintained for years, superceded 
 Who:	Jeff Garzik <jeff@garzik.org>
 
 ---------------------------
+
+What:   sk98lin network driver
+When:   July 2007
+Why:    In kernel tree version of driver is unmaintained. Sk98lin driver
+	replaced by the skge driver. 
+Who:    Stephen Hemminger <shemminger@osdl.org>
+
-- 
1.4.1
