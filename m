From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH iproute2 net-next] bridge: man: fix "brige" typo
Date: Tue, 21 Jun 2016 15:28:50 -0400
Message-ID: <20160621192850.9454-1-vivien.didelot@savoirfairelinux.com>
Cc: Stephen Hemminger <shemming@brocade.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:37129 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751599AbcFUT3g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 15:29:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 man/man8/bridge.8 | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man/man8/bridge.8 b/man/man8/bridge.8
index 1818542..ac42118 100644
--- a/man/man8/bridge.8
+++ b/man/man8/bridge.8
@@ -234,7 +234,7 @@ error.
 .sp
 
 .B 1
-- STP LISTENING state. Only valid if STP is enabled on the brige. In this
+- STP LISTENING state. Only valid if STP is enabled on the bridge. In this
 state the port for list for STP BPDUs and drop all other traffic.
 .sp
 
-- 
2.9.0
