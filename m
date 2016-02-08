From: "=?UTF-8?q?Jo=C3=A3o=20Paulo=20Rechi=20Vita?=" <jprvita@gmail.com>
Subject: [PATCH 2/9] rfkill: Remove extra blank line
Date: Mon,  8 Feb 2016 10:41:29 -0500
Message-ID: <1454946096-9752-3-git-send-email-jprvita@endlessm.com>
References: <1454946096-9752-1-git-send-email-jprvita@endlessm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Darren Hart <dvhart@infradead.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	platform-driver-x86@vger.kernel.org, linux-api@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux@endlessm.com,
	=?UTF-8?q?Jo=C3=A3o=20Paulo=20Rechi=20Vita?= <jprvita@endlessm.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <platform-driver-x86-owner@vger.kernel.org>
In-Reply-To: <1454946096-9752-1-git-send-email-jprvita@endlessm.com>
Sender: platform-driver-x86-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Jo=C3=A3o Paulo Rechi Vita <jprvita@endlessm.com>
---
 net/rfkill/core.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/rfkill/core.c b/net/rfkill/core.c
index ffbc375..56d79cb 100644
--- a/net/rfkill/core.c
+++ b/net/rfkill/core.c
@@ -455,7 +455,6 @@ bool rfkill_get_global_sw_state(const enum rfkill_t=
ype type)
 }
 #endif
=20
-
 bool rfkill_set_hw_state(struct rfkill *rfkill, bool blocked)
 {
 	unsigned long flags;
--=20
2.5.0
