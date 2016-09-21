From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next] MAINTAINERS: Update b44 maintainer.
Date: Tue, 20 Sep 2016 23:33:15 -0400
Message-ID: <1474428795-25095-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:34029 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753797AbcIUDdZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 23:33:25 -0400
Received: by mail-pf0-f179.google.com with SMTP id p64so14129855pfb.1
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 20:33:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Taking over as maintainer since Gary Zambrano is no longer working
for Broadcom.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 MAINTAINERS | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index ce80b36..7626f7836 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2509,7 +2509,7 @@ S:	Supported
 F:	kernel/bpf/
 
 BROADCOM B44 10/100 ETHERNET DRIVER
-M:	Gary Zambrano <zambrano@broadcom.com>
+M:	Michael Chan <michael.chan@broadcom.com>
 L:	netdev@vger.kernel.org
 S:	Supported
 F:	drivers/net/ethernet/broadcom/b44.*
-- 
1.8.3.1
