From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 3/5] man: tc-u32: Minor syntax fix
Date: Fri,  4 Mar 2016 12:52:39 +0100
Message-ID: <1457092361-17603-4-git-send-email-phil@nwl.cc>
References: <1457092361-17603-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:35337 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751454AbcCDLxG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Mar 2016 06:53:06 -0500
In-Reply-To: <1457092361-17603-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/tc-u32.8 | 1 +
 1 file changed, 1 insertion(+)

diff --git a/man/man8/tc-u32.8 b/man/man8/tc-u32.8
index 47c8f2d092ee8..691f53c135cfe 100644
--- a/man/man8/tc-u32.8
+++ b/man/man8/tc-u32.8
@@ -370,6 +370,7 @@ then allows to match various header fields:
 .RS
 .TP
 .BI src " ADDR"
+.TQ
 .BI dst " ADDR"
 Compare Source or Destination Address fields against the value of
 .IR ADDR .
-- 
2.7.2
