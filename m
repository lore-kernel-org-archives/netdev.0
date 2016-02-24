From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 09/20] man: ip-link.8: minor font fix
Date: Wed, 24 Feb 2016 09:21:22 +0100
Message-ID: <1456302093-697-10-git-send-email-phil@nwl.cc>
References: <1456302093-697-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:49147 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758073AbcBXIXd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2016 03:23:33 -0500
In-Reply-To: <1456302093-697-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We commonly use bold font for terminals and italic for non-terminals.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/ip-link.8.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 4d3234352004e..27c9a321c2af8 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -49,7 +49,7 @@ ip-link \- network device configuration
 .RB "[ " numrxqueues
 .IR QUEUE_COUNT " ]"
 .br
-.BR type " TYPE"
+.BI type " TYPE"
 .RI "[ " ARGS " ]"
 
 .ti -8
-- 
2.6.4
