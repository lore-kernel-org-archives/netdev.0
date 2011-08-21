From: Geoffrey Thomas <geofft@MIT.EDU>
Subject: [PATCH] Documentation: RFC 2553bis is now RFC 3493
Date: Sun, 21 Aug 2011 16:13:14 -0400
Message-ID: <1313957594-22265-1-git-send-email-geofft@mit.edu>
Cc: Geoffrey Thomas <geofft@mit.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DMZ-MAILSEC-SCANNER-8.MIT.EDU ([18.7.68.37]:53234 "EHLO
	dmz-mailsec-scanner-8.mit.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751992Ab1HUUNc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Aug 2011 16:13:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Geoffrey Thomas <geofft@mit.edu>
---
 Documentation/networking/ip-sysctl.txt |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index db2a406..8154699 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -992,7 +992,7 @@ bindv6only - BOOLEAN
 		TRUE: disable IPv4-mapped address feature
 		FALSE: enable IPv4-mapped address feature
 
-	Default: FALSE (as specified in RFC2553bis)
+	Default: FALSE (as specified in RFC3493)
 
 IPv6 Fragmentation:
 
-- 
1.7.2.5

