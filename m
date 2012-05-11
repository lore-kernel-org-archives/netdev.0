From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 15/15] batman-adv: add contributor name
Date: Fri, 11 May 2012 14:21:32 +0200
Message-ID: <1336738892-7401-16-git-send-email-ordex@autistici.org>
References: <1336738892-7401-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:58895 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758391Ab2EKMZh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2012 08:25:37 -0400
In-Reply-To: <1336738892-7401-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

translation_table.{c,h} have been heavily modified by another contributor and
for legal purposes it is better to include his name into the contributor list

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/translation-table.c |    2 +-
 net/batman-adv/translation-table.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index a38d315..2cb46f0 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -1,7 +1,7 @@
 /*
  * Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
  *
- * Marek Lindner, Simon Wunderlich
+ * Marek Lindner, Simon Wunderlich, Antonio Quartulli
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of version 2 of the GNU General Public
diff --git a/net/batman-adv/translation-table.h b/net/batman-adv/translation-table.h
index bfebe26..593d1b3 100644
--- a/net/batman-adv/translation-table.h
+++ b/net/batman-adv/translation-table.h
@@ -1,7 +1,7 @@
 /*
  * Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
  *
- * Marek Lindner, Simon Wunderlich
+ * Marek Lindner, Simon Wunderlich, Antonio Quartulli
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of version 2 of the GNU General Public
-- 
1.7.9.4
