From: Marcos Paulo de Souza <marcos.mage@gmail.com>
Subject: [PATCH] Documentation: networking: dmfe.txt: Remove the maintainer of orphan filesystem
Date: Tue, 30 Aug 2011 12:33:57 -0300
Message-ID: <1314718437-5794-1-git-send-email-marcos.mage@gmail.com>
Cc: netdev@vger.kernel.org, linux-doc@vger.kernel.org,
	Marcos Paulo de Souza <marcos.mage@gmail.com>
To: rdunlap@xenotime.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:54131 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755275Ab1H3PeK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 11:34:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The dmfe module is a orphan driver, and with this was removed the maintainer
of the documentation.

Signed-off-by: Marcos Paulo de Souza <marcos.mage@gmail.com>
---
 Documentation/networking/dmfe.txt |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/Documentation/networking/dmfe.txt b/Documentation/networking/dmfe.txt
index 8006c22..25320bf 100644
--- a/Documentation/networking/dmfe.txt
+++ b/Documentation/networking/dmfe.txt
@@ -1,3 +1,5 @@
+Note: This driver doesn't have a maintainer.
+
 Davicom DM9102(A)/DM9132/DM9801 fast ethernet driver for Linux.
 
 This program is free software; you can redistribute it and/or
@@ -55,7 +57,6 @@ Test and make sure PCI latency is now correct for all cases.
 Authors:
 
 Sten Wang <sten_wang@davicom.com.tw >   : Original Author
-Tobias Ringstrom <tori@unhappy.mine.nu> : Current Maintainer
 
 Contributors:
 
-- 
1.7.4.1
