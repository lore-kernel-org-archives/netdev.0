From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 12/14] SCTP: Clean-up some defines for regressions tests.
Date: Mon, 12 Nov 2007 11:38:27 -0500
Message-ID: <1194885518275-git-send-email-vladislav.yasevich@hp.com>
References: <11948855091808-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:59067 "EHLO palrel13.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754946AbXKLQir (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Nov 2007 11:38:47 -0500
In-Reply-To: <11948855091808-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/sctp.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 67c997c..34318a3 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -65,7 +65,6 @@
 
 
 #ifdef TEST_FRAME
-#undef CONFIG_PROC_FS
 #undef CONFIG_SCTP_DBG_OBJCNT
 #undef CONFIG_SYSCTL
 #endif /* TEST_FRAME */
-- 
1.5.2.4

