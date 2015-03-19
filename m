From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] man ip-link: Add ip-netns(8) in 'SEE ALSO'
Date: Thu, 19 Mar 2015 23:09:28 +0200
Message-ID: <1426799368-22829-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:32974 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751144AbbCSVVO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 17:21:14 -0400
Received: by lbnq5 with SMTP id q5so34192205lbn.0
        for <netdev@vger.kernel.org>; Thu, 19 Mar 2015 14:21:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 man/man8/ip-link.8.in | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 9bbf2d3..0e3bb5e 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -900,7 +900,8 @@ and the outer UDP checksum and remote checksum offload are enabled.
 
 .SH SEE ALSO
 .br
-.BR ip (8)
+.BR ip (8),
+.BR ip-netns (8)
 
 .SH AUTHOR
 Original Manpage by Michail Litvak <mci@owl.openwall.com>
-- 
2.3.1
