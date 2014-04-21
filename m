From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 4/4] MAINTAINERS: add Broadcom SYSTEMPORT driver entry
Date: Mon, 21 Apr 2014 10:31:34 -0700
Message-ID: <1398101494-27959-5-git-send-email-f.fainelli@gmail.com>
References: <1398101494-27959-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:56135 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752443AbaDURbu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 13:31:50 -0400
Received: by mail-ig0-f176.google.com with SMTP id uy17so2016856igb.15
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2014 10:31:50 -0700 (PDT)
In-Reply-To: <1398101494-27959-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add an entry in the MAINTAINERS file listing myself as the maintainer
for the Broadcom SYSTEMPORT Ethernet MAC controller driver.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 MAINTAINERS | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index e67ea2442041..981a19307036 100644
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
