From: Wolfgang Grandegger <wg@grandegger.com>
Subject: [PATCH 2/8] can: Update MAINTAINERS and CREDITS file
Date: Thu, 19 Feb 2009 20:01:16 +0100
Message-ID: <1235070082-7069-3-git-send-email-wg@grandegger.com>
References: <1235070082-7069-1-git-send-email-wg@grandegger.com>
 <1235070082-7069-2-git-send-email-wg@grandegger.com>
Cc: linux-kernel@vger.kernel.org,
	Wolfgang Grandegger <wg@grandegger.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:55175 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754127AbZBSTB3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2009 14:01:29 -0500
In-Reply-To: <1235070082-7069-2-git-send-email-wg@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>
---
 CREDITS     |    4 ++++
 MAINTAINERS |    7 +++++++
 2 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/CREDITS b/CREDITS
index 2b39168..ecbf6a2 100644
--- a/CREDITS
+++ b/CREDITS
@@ -1248,6 +1248,10 @@ S: 8124 Constitution Apt. 7
 S: Sterling Heights, Michigan 48313
 S: USA
 
+N: Wolfgang Grandegger
+E: wg@grandegger.com
+D: Controller Area Network (device drivers)
+
 N: William Greathouse
 E: wgreathouse@smva.com
 E: wgreathouse@myfavoritei.com
diff --git a/MAINTAINERS b/MAINTAINERS
index db65b4e..7bbf231 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1063,6 +1063,13 @@ L:	socketcan-core@lists.berlios.de (subscribers-only)
 W:	http://developer.berlios.de/projects/socketcan/
 S:	Maintained
 
+CAN NETWORK DRIVERS
+P:	Wolfgang Grandegger
+M:	wg@grandegger.com
+L:	socketcan-core@lists.berlios.de (subscribers-only)
+W:	http://developer.berlios.de/projects/socketcan/
+S:	Maintained
+
 CELL BROADBAND ENGINE ARCHITECTURE
 P:	Arnd Bergmann
 M:	arnd@arndb.de
-- 
1.5.6.6

