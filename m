From: "John W. Linville" <linville@tuxdriver.com>
Subject: [RFC PATCH 4/5] libgeneve: identify as driver library in modules description
Date: Thu,  2 Apr 2015 15:17:05 -0400
Message-ID: <1428002227-11636-5-git-send-email-linville@tuxdriver.com>
References: <1428002227-11636-1-git-send-email-linville@tuxdriver.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>, Andy Zhou <azhou@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:49875 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751166AbbDBTTN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 15:19:13 -0400
In-Reply-To: <1428002227-11636-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
 net/ipv4/libgeneve.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/libgeneve.c b/net/ipv4/libgeneve.c
index 7990075d3fc8..1083ebd84ab6 100644
--- a/net/ipv4/libgeneve.c
+++ b/net/ipv4/libgeneve.c
@@ -444,4 +444,4 @@ module_exit(geneve_cleanup_module);
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jesse Gross <jesse@nicira.com>");
-MODULE_DESCRIPTION("Driver for GENEVE encapsulated traffic");
+MODULE_DESCRIPTION("Driver library for GENEVE encapsulated traffic");
-- 
2.1.0
