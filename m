From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH iproute2] bridge: man: fix STP LISTENING description
Date: Wed, 29 Jun 2016 15:26:29 -0400
Message-ID: <20160629192629.1434-1-vivien.didelot@savoirfairelinux.com>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Stephen Hemminger <shemming@brocade.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:34038 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751480AbcF2T1l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 15:27:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Correct the unclear and poorly conjugated STP LISTENING documentation.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 man/man8/bridge.8 | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man/man8/bridge.8 b/man/man8/bridge.8
index ac42118..8a39673 100644
--- a/man/man8/bridge.8
+++ b/man/man8/bridge.8
@@ -235,7 +235,7 @@ error.
 
 .B 1
 - STP LISTENING state. Only valid if STP is enabled on the bridge. In this
-state the port for list for STP BPDUs and drop all other traffic.
+state the port listens for STP BPDUs and drops all other traffic frames.
 .sp
 
 .B 2
-- 
2.9.0
