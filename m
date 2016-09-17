From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] MAINTAINERS: Gary Zambrano's email is bouncing
Date: Sat, 17 Sep 2016 15:27:15 -0700
Message-ID: <1474151235-16558-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, michael.chan@broadcom.com,
        bcm-kernel-feedback-list@broadcom.com, zajec5@gmail.com,
        hauke@hauke-m.de, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:32783 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754187AbcIQW1U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2016 18:27:20 -0400
Received: by mail-oi0-f67.google.com with SMTP id w11so9499306oia.0
        for <netdev@vger.kernel.org>; Sat, 17 Sep 2016 15:27:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gary has not been with Broadcom for some time now, replace his address
with the internal mailing-list used for other entries.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Michael,

Since this is an old driver, not sure who could step up as a maintainer
for b44?

 MAINTAINERS | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index a5e1270dfbf1..dffc3bca17ee 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2500,8 +2500,8 @@ S:	Supported
 F:	kernel/bpf/
 
 BROADCOM B44 10/100 ETHERNET DRIVER
-M:	Gary Zambrano <zambrano@broadcom.com>
 L:	netdev@vger.kernel.org
+M:	bcm-kernel-feedback-list@broadcom.com
 S:	Supported
 F:	drivers/net/ethernet/broadcom/b44.*
 
-- 
2.7.4
