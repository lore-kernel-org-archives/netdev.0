From: Petr Sabata <psabata@redhat.com>
Subject: [PATCH] ss: Change "do now" to "do not" in ss(8), -n option
Date: Wed,  8 Dec 2010 14:49:09 +0100
Message-ID: <1291816149-15782-1-git-send-email-psabata@redhat.com>
Cc: Petr Sabata <psabata@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51182 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754243Ab0LHNtR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Dec 2010 08:49:17 -0500
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id oB8DnG03000323
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 8 Dec 2010 08:49:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A small typo fix.

---
 man/man8/ss.8 |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/man/man8/ss.8 b/man/man8/ss.8
index f261cf2..b309df2 100644
--- a/man/man8/ss.8
+++ b/man/man8/ss.8
@@ -26,7 +26,7 @@ Show summary of options.
 Output version information.
 .TP
 .B \-n, \-\-numeric
-Do now try to resolve service names.
+Do not try to resolve service names.
 .TP
 .B \-r, \-\-resolve
 Try to resolve numeric address/ports.
-- 
1.7.3.2

