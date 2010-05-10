From: kaber@trash.net
Subject: [PATCH 12/84] netfilter: ebt_ip6: add principal maintainer in a MODULE_AUTHOR tag
Date: Mon, 10 May 2010 22:17:43 +0200
Message-ID: <1273522735-24672-13-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@medozas.de>

Cc: Kuo-Lang Tseng <kuo-lang.tseng@intel.com>
Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 net/bridge/netfilter/ebt_ip6.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/bridge/netfilter/ebt_ip6.c b/net/bridge/netfilter/ebt_ip6.c
index 4cb60f1..05d0d0c 100644
--- a/net/bridge/netfilter/ebt_ip6.c
+++ b/net/bridge/netfilter/ebt_ip6.c
@@ -139,4 +139,5 @@ static void __exit ebt_ip6_fini(void)
 module_init(ebt_ip6_init);
 module_exit(ebt_ip6_fini);
 MODULE_DESCRIPTION("Ebtables: IPv6 protocol packet match");
+MODULE_AUTHOR("Kuo-Lang Tseng <kuo-lang.tseng@intel.com>");
 MODULE_LICENSE("GPL");
-- 
1.7.0.4

