From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 03/14] netfilter: nf_tables: fix spelling mistakes
Date: Thu, 26 Jan 2017 17:37:56 +0100
Message-ID: <1485448687-6072-4-git-send-email-pablo@netfilter.org>
References: <1485448687-6072-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1485448687-6072-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Alemayhu <alexander@alemayhu.com>

o s/numerice/numeric
o s/opertaor/operator

Signed-off-by: Alexander Alemayhu <alexander@alemayhu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nf_tables.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index 881d49e94569..e3f27e09eb2b 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -235,7 +235,7 @@ enum nft_rule_compat_flags {
 /**
  * enum nft_rule_compat_attributes - nf_tables rule compat attributes
  *
- * @NFTA_RULE_COMPAT_PROTO: numerice value of handled protocol (NLA_U32)
+ * @NFTA_RULE_COMPAT_PROTO: numeric value of handled protocol (NLA_U32)
  * @NFTA_RULE_COMPAT_FLAGS: bitmask of enum nft_rule_compat_flags (NLA_U32)
  */
 enum nft_rule_compat_attributes {
@@ -499,7 +499,7 @@ enum nft_bitwise_attributes {
  * enum nft_byteorder_ops - nf_tables byteorder operators
  *
  * @NFT_BYTEORDER_NTOH: network to host operator
- * @NFT_BYTEORDER_HTON: host to network opertaor
+ * @NFT_BYTEORDER_HTON: host to network operator
  */
 enum nft_byteorder_ops {
 	NFT_BYTEORDER_NTOH,
-- 
2.1.4

