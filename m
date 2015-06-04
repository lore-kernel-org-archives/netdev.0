From: sfeldma@gmail.com
Subject: [PATCH net-next 2/4] switchdev: documentation: fix grammer error
Date: Wed,  3 Jun 2015 20:43:41 -0700
Message-ID: <1433389423-58467-3-git-send-email-sfeldma@gmail.com>
References: <1433389423-58467-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, gospo@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:32857 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751337AbbFDDlq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 23:41:46 -0400
Received: by padj3 with SMTP id j3so20374359pad.0
        for <netdev@vger.kernel.org>; Wed, 03 Jun 2015 20:41:45 -0700 (PDT)
In-Reply-To: <1433389423-58467-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 Documentation/networking/switchdev.txt |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Documentation/networking/switchdev.txt b/Documentation/networking/switchdev.txt
index 5061d6e..0554b68 100644
--- a/Documentation/networking/switchdev.txt
+++ b/Documentation/networking/switchdev.txt
@@ -142,7 +142,7 @@ The port netdevs representing the physical switch ports can be organized into
 higher-level switching constructs.  The default construct is a standalone
 router port, used to offload L3 forwarding.  Two or more ports can be bonded
 together to form a LAG.  Two or more ports (or LAGs) can be bridged to bridge
-to L2 networks.  VLANs can be applied to sub-divide L2 networks.  L2-over-L3
+L2 networks.  VLANs can be applied to sub-divide L2 networks.  L2-over-L3
 tunnels can be built on ports.  These constructs are built using standard Linux
 tools such as the bridge driver, the bonding/team drivers, and netlink-based
 tools such as iproute2.
-- 
1.7.10.4
