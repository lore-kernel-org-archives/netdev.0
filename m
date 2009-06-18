From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/5] MAINTAINERS: Fix Atheros pattern paths
Date: Thu, 18 Jun 2009 11:08:01 -0700
Message-ID: <8ee51d1f4d9f1076ae013721d189c7b0d9db2df8.1245345515.git.joe@perches.com>
References: <cover.1245345515.git.joe@perches.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Bob Copeland <me@bobcopeland.com>,
	"Luis R . Rodriguez" <lrodriguez@atheros.com>,
	Nick Kossifidis <mickflemm@gmail.com>,
	Jiri Slaby <jirislaby@gmail.com>, ath5k-devel@venema.h4ckr.net,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:1512 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754041AbZFRSIF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 14:08:05 -0400
In-Reply-To: <cover.1245345515.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 MAINTAINERS |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index fb94add..4e73646 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -946,7 +946,7 @@ M:	me@bobcopeland.com
 L:	linux-wireless@vger.kernel.org
 L:	ath5k-devel@lists.ath5k.org
 S:	Maintained
-F:	drivers/net/wireless/ath5k/
+F:	drivers/net/wireless/ath/ath5k/
 
 ATHEROS ATH9K WIRELESS DRIVER
 P:	Luis R. Rodriguez
@@ -962,7 +962,7 @@ M:	senthilkumar@atheros.com
 L:	linux-wireless@vger.kernel.org
 L:	ath9k-devel@lists.ath9k.org
 S:	Supported
-F:	drivers/net/wireless/ath9k/
+F:	drivers/net/wireless/ath/ath9k/
 
 ATHEROS AR9170 WIRELESS DRIVER
 P:	Christian Lamparter
@@ -970,7 +970,7 @@ M:	chunkeey@web.de
 L:	linux-wireless@vger.kernel.org
 W:	http://wireless.kernel.org/en/users/Drivers/ar9170
 S:	Maintained
-F:	drivers/net/wireless/ar9170/
+F:	drivers/net/wireless/ath/ar9170/
 
 ATI_REMOTE2 DRIVER
 P:	Ville Syrjala
-- 
1.6.3.1.10.g659a0.dirty

