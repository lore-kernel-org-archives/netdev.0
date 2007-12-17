From: Joe Perches <joe@perches.com>
Subject: [PATCH] net/ipv4/: Spelling fixes
Date: Mon, 17 Dec 2007 11:40:31 -0800
Message-ID: <5703e57f925f31fc0eb38873bd7f10fc44f99cb4.1197918894.git.joe__28450.8683639162$1197920672$gmane$org@perches.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@trash.net>, coreteam@netfilter.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netfilter-owner@vger.kernel.org>
Message-Id: <5703e57f925f31fc0eb38873bd7f10fc44f99cb4.1197918894.git.joe@perches.com>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Joe Perches <joe@perches.com>
---
 net/ipv4/netfilter/nf_nat_sip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/netfilter/nf_nat_sip.c b/net/ipv4/netfilter/nf_nat_sip.c
index 3ca9897..8996ccb 100644
--- a/net/ipv4/netfilter/nf_nat_sip.c
+++ b/net/ipv4/netfilter/nf_nat_sip.c
@@ -165,7 +165,7 @@ static int mangle_content_len(struct sk_buff *skb,
 
 	dataoff = ip_hdrlen(skb) + sizeof(struct udphdr);
 
-	/* Get actual SDP lenght */
+	/* Get actual SDP length */
 	if (ct_sip_get_info(ct, dptr, skb->len - dataoff, &matchoff,
 			    &matchlen, POS_SDP_HEADER) > 0) {
 
-- 
1.5.3.7.949.g2221a6

