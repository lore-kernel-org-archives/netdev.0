From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 09/20] man: ip-link.8: minor font fix
Date: Wed,  2 Mar 2016 19:19:57 +0100
Message-ID: <1456942808-15946-10-git-send-email-phil@nwl.cc>
References: <20160302093800.7e7dbe71@xeon-e3>
 <1456942808-15946-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:45986 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750898AbcCBSUV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2016 13:20:21 -0500
In-Reply-To: <1456942808-15946-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We commonly use bold font for terminals and italic for non-terminals.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/ip-link.8.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 221831e52bc9a..2376f1653a8f2 100644
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
2.7.2
