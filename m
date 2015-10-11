From: Ian Morris <ipm@chirality.org.uk>
Subject: [PATCH nf-next 1/7] netfilter-ipv6: label placement
Date: Sun, 11 Oct 2015 17:32:14 +0100
Message-ID: <1444581140-6255-2-git-send-email-ipm@chirality.org.uk>
References: <1444581140-6255-1-git-send-email-ipm@chirality.org.uk>
Cc: Ian Morris <ipm@chirality.org.uk>
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1444581140-6255-1-git-send-email-ipm@chirality.org.uk>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Whitespace cleansing: Labels should not be indented.

No changes detected by objdiff.

Signed-off-by: Ian Morris <ipm@chirality.org.uk>
---
 net/ipv6/netfilter/ip6_tables.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 80e3bd7..67a2821 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -561,7 +561,7 @@ mark_source_chains(const struct xt_table_info *newinfo,
 				pos = newpos;
 			}
 		}
-		next:
+next:
 		duprintf("Finished chain %u\n", hook);
 	}
 	return 1;
-- 
1.9.1

