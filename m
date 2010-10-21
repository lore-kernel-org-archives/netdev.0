From: kaber@trash.net
Subject: [PATCH 29/72] netfilter: remove duplicated include
Date: Thu, 21 Oct 2010 17:19:16 +0200
Message-ID: <1287674399-31455-30-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicolas Kaiser <nikai@nikai.net>

Remove duplicated include.

Signed-off-by: Nicolas Kaiser <nikai@nikai.net>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/xt_ipvs.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/xt_ipvs.c b/net/netfilter/xt_ipvs.c
index 7a4d66d..9127a3d 100644
--- a/net/netfilter/xt_ipvs.c
+++ b/net/netfilter/xt_ipvs.c
@@ -16,7 +16,6 @@
 #include <linux/ip_vs.h>
 #include <linux/types.h>
 #include <linux/netfilter/x_tables.h>
-#include <linux/netfilter/x_tables.h>
 #include <linux/netfilter/xt_ipvs.h>
 #include <net/netfilter/nf_conntrack.h>
 
-- 
1.7.1

