From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH iproute2] bridge: man: fix BPUD typo
Date: Wed, 29 Jun 2016 15:26:10 -0400
Message-ID: <20160629192610.1328-1-vivien.didelot@savoirfairelinux.com>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Stephen Hemminger <shemming@brocade.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:34019 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751465AbcF2T01 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 15:26:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

s/BPUD/BPDU/ in guard description.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 man/man8/bridge.8 | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man/man8/bridge.8 b/man/man8/bridge.8
index 8a39673..ef4f83e 100644
--- a/man/man8/bridge.8
+++ b/man/man8/bridge.8
@@ -256,7 +256,7 @@ STP BPDUs.
 
 .TP
 .BR "guard on " or " guard off "
-Controls whether STP BPUDs will be processed by the bridge port. By default,
+Controls whether STP BPDUs will be processed by the bridge port. By default,
 the flag is turned off allowed BPDU processing. Turning this flag on will
 cause the port to stop processing STP BPDUs.
 
-- 
2.9.0
