From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 03/50] netfilter: update Arturo Borrero Gonzalez email address
Date: Wed,  7 Dec 2016 22:52:09 +0100
Message-ID: <1481147576-5690-4-git-send-email-pablo@netfilter.org>
References: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arturo Borrero Gonzalez <arturo@debian.org>

The email address has changed, let's update the copyright statements.

Signed-off-by: Arturo Borrero Gonzalez <arturo@debian.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/nft_masq_ipv4.c  | 4 ++--
 net/ipv4/netfilter/nft_redir_ipv4.c | 4 ++--
 net/ipv6/netfilter/nft_masq_ipv6.c  | 4 ++--
 net/ipv6/netfilter/nft_redir_ipv6.c | 4 ++--
 net/netfilter/nft_masq.c            | 4 ++--
 net/netfilter/nft_redir.c           | 4 ++--
 6 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/netfilter/nft_masq_ipv4.c b/net/ipv4/netfilter/nft_masq_ipv4.c
index 4f697e431811..4d69f99b8707 100644
--- a/net/ipv4/netfilter/nft_masq_ipv4.c
+++ b/net/ipv4/netfilter/nft_masq_ipv4.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2014 Arturo Borrero Gonzalez <arturo.borrero.glez@gmail.com>
+ * Copyright (c) 2014 Arturo Borrero Gonzalez <arturo@debian.org>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -77,5 +77,5 @@ module_init(nft_masq_ipv4_module_init);
 module_exit(nft_masq_ipv4_module_exit);
 
 MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Arturo Borrero Gonzalez <arturo.borrero.glez@gmail.com>");
+MODULE_AUTHOR("Arturo Borrero Gonzalez <arturo@debian.org");
 MODULE_ALIAS_NFT_AF_EXPR(AF_INET, "masq");
diff --git a/net/ipv4/netfilter/nft_redir_ipv4.c b/net/ipv4/netfilter/nft_redir_ipv4.c
index 16df0493c5ce..62c18e68ac58 100644
--- a/net/ipv4/netfilter/nft_redir_ipv4.c
+++ b/net/ipv4/netfilter/nft_redir_ipv4.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2014 Arturo Borrero Gonzalez <arturo.borrero.glez@gmail.com>
+ * Copyright (c) 2014 Arturo Borrero Gonzalez <arturo@debian.org>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -71,5 +71,5 @@ module_init(nft_redir_ipv4_module_init);
 module_exit(nft_redir_ipv4_module_exit);
 
 MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Arturo Borrero Gonzalez <arturo.borrero.glez@gmail.com>");
+MODULE_AUTHOR("Arturo Borrero Gonzalez <arturo@debian.org>");
 MODULE_ALIAS_NFT_AF_EXPR(AF_INET, "redir");
diff --git a/net/ipv6/netfilter/nft_masq_ipv6.c b/net/ipv6/netfilter/nft_masq_ipv6.c
index a2aff1277b40..93d758f70334 100644
--- a/net/ipv6/netfilter/nft_masq_ipv6.c
+++ b/net/ipv6/netfilter/nft_masq_ipv6.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2014 Arturo Borrero Gonzalez <arturo.borrero.glez@gmail.com>
+ * Copyright (c) 2014 Arturo Borrero Gonzalez <arturo@debian.org>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -78,5 +78,5 @@ module_init(nft_masq_ipv6_module_init);
 module_exit(nft_masq_ipv6_module_exit);
 
 MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Arturo Borrero Gonzalez <arturo.borrero.glez@gmail.com>");
+MODULE_AUTHOR("Arturo Borrero Gonzalez <arturo@debian.org>");
 MODULE_ALIAS_NFT_AF_EXPR(AF_INET6, "masq");
diff --git a/net/ipv6/netfilter/nft_redir_ipv6.c b/net/ipv6/netfilter/nft_redir_ipv6.c
index bfcd5af6bc15..2850fcd8583f 100644
--- a/net/ipv6/netfilter/nft_redir_ipv6.c
+++ b/net/ipv6/netfilter/nft_redir_ipv6.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2014 Arturo Borrero Gonzalez <arturo.borrero.glez@gmail.com>
+ * Copyright (c) 2014 Arturo Borrero Gonzalez <arturo@debian.org>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -72,5 +72,5 @@ module_init(nft_redir_ipv6_module_init);
 module_exit(nft_redir_ipv6_module_exit);
 
 MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Arturo Borrero Gonzalez <arturo.borrero.glez@gmail.com>");
+MODULE_AUTHOR("Arturo Borrero Gonzalez <arturo@debian.org>");
 MODULE_ALIAS_NFT_AF_EXPR(AF_INET6, "redir");
diff --git a/net/netfilter/nft_masq.c b/net/netfilter/nft_masq.c
index 81b5ad6165ac..bf92de01410f 100644
--- a/net/netfilter/nft_masq.c
+++ b/net/netfilter/nft_masq.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2014 Arturo Borrero Gonzalez <arturo.borrero.glez@gmail.com>
+ * Copyright (c) 2014 Arturo Borrero Gonzalez <arturo@debian.org>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -105,4 +105,4 @@ int nft_masq_dump(struct sk_buff *skb, const struct nft_expr *expr)
 EXPORT_SYMBOL_GPL(nft_masq_dump);
 
 MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Arturo Borrero Gonzalez <arturo.borrero.glez@gmail.com>");
+MODULE_AUTHOR("Arturo Borrero Gonzalez <arturo@debian.org>");
diff --git a/net/netfilter/nft_redir.c b/net/netfilter/nft_redir.c
index 03f7bf40ae75..967e09b099b2 100644
--- a/net/netfilter/nft_redir.c
+++ b/net/netfilter/nft_redir.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2014 Arturo Borrero Gonzalez <arturo.borrero.glez@gmail.com>
+ * Copyright (c) 2014 Arturo Borrero Gonzalez <arturo@debian.org>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -108,4 +108,4 @@ int nft_redir_dump(struct sk_buff *skb, const struct nft_expr *expr)
 EXPORT_SYMBOL_GPL(nft_redir_dump);
 
 MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Arturo Borrero Gonzalez <arturo.borrero.glez@gmail.com>");
+MODULE_AUTHOR("Arturo Borrero Gonzalez <arturo@debian.org>");
-- 
2.1.4

