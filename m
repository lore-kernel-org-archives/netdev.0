From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH iproute2 1/4] include: update kernel headers
Date: Mon,  4 Jan 2016 10:58:03 +0100
Message-ID: <1451901486-3497-2-git-send-email-bjorn@mork.no>
References: <1451901486-3497-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:38826 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753136AbcADJ6e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2016 04:58:34 -0500
In-Reply-To: <1451901486-3497-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Import current if_link.h from net-next

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 include/linux/if_link.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index c9ad487d04f0..d91f2c97d946 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -216,6 +216,7 @@ enum in6_addr_gen_mode {
 	IN6_ADDR_GEN_MODE_EUI64,
 	IN6_ADDR_GEN_MODE_NONE,
 	IN6_ADDR_GEN_MODE_STABLE_PRIVACY,
+	IN6_ADDR_GEN_MODE_RANDOM,
 };
=20
 /* Bridge section */
--=20
2.1.4
