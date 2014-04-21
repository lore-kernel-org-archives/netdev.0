From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] MAINTAINERS: SXGBE authors update
Date: Mon, 21 Apr 2014 09:12:08 -0700
Message-ID: <1398096728-8897-1-git-send-email-f.fainelli@gmail.com>
Cc: bh74.an@samsung.com, ks.giri@samsung.com, davem@davemloft.net,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:39357 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751238AbaDUQM3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 12:12:29 -0400
Received: by mail-pd0-f175.google.com with SMTP id x10so3819740pdj.34
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2014 09:12:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mail address for Siva Reddy Kallam is bouncing, remove the email
address from the MAINTAINERS entry for Samsung's SXGBE driver.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 MAINTAINERS | 1 -
 1 file changed, 1 deletion(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index e67ea2442041..1241a73cc230 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -7674,7 +7674,6 @@ F:	drivers/clk/samsung/
 SAMSUNG SXGBE DRIVERS
 M:	Byungho An <bh74.an@samsung.com>
 M:	Girish K S <ks.giri@samsung.com>
-M:	Siva Reddy Kallam <siva.kallam@samsung.com>
 M:	Vipul Pandya <vipul.pandya@samsung.com>
 S:	Supported
 L:	netdev@vger.kernel.org
-- 
1.9.1
