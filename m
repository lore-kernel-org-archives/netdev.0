From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 4/4] MAINTAINERS: add Broadcom SYSTEMPORT driver entry
Date: Thu, 24 Apr 2014 18:09:00 -0700
Message-ID: <1398388140-8003-5-git-send-email-f.fainelli@gmail.com>
References: <1398388140-8003-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:64824 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750818AbaDYBJ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 21:09:27 -0400
Received: by mail-pb0-f48.google.com with SMTP id md12so2567845pbc.7
        for <netdev@vger.kernel.org>; Thu, 24 Apr 2014 18:09:27 -0700 (PDT)
In-Reply-To: <1398388140-8003-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add an entry in the MAINTAINERS file listing myself as the maintainer
for the Broadcom SYSTEMPORT Ethernet MAC controller driver.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 MAINTAINERS | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 1241a73cc230..7bb7eadd078c 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1967,6 +1967,12 @@ S:	Maintained
 F:	drivers/bcma/
 F:	include/linux/bcma/
 
+BROADCOM SYSTEMPORT ETHERNET DRIVER
+M:	Florian Fainelli <f.fainelli@gmail.com>
+L:	netdev@vger.kernel.org
+S:	Supported
+F:	drivers/net/ethernet/broadcom/bcmsysport.*
+
 BROCADE BFA FC SCSI DRIVER
 M:	Anil Gurumurthy <anil.gurumurthy@qlogic.com>
 M:	Sudarsana Kalluru <sudarsana.kalluru@qlogic.com>
-- 
1.9.1
