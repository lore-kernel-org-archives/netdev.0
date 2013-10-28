From: =?UTF-8?q?Michael=20Dr=C3=BCing?= <michael@drueing.de>
Subject: [PATCH] net: x25: Fix dead URLs in Kconfig
Date: Mon, 28 Oct 2013 18:33:12 +0100
Message-ID: <1382981592-7449-1-git-send-email-michael@drueing.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: andrew.hendry@gmail.com, linux-x25@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	=?UTF-8?q?Michael=20Dr=C3=BCing?= <michael@drueing.de>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update the URLs in the Kconfig file to the new pages at sangoma.com and=
 cisco.com

Signed-off-by: Michael Dr=C3=BCing <michael@drueing.de>
---
 net/x25/Kconfig | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/x25/Kconfig b/net/x25/Kconfig
index c959312c..e2fa133 100644
--- a/net/x25/Kconfig
+++ b/net/x25/Kconfig
@@ -16,8 +16,8 @@ config X25
 	  if you want that) and the lower level data link layer protocol LAPB
 	  (say Y to "LAPB Data Link Driver" below if you want that).
=20
-	  You can read more about X.25 at <http://www.sangoma.com/x25.htm> an=
d
-	  <http://www.cisco.com/univercd/cc/td/doc/product/software/ios11/cbo=
ok/cx25.htm>.
+	  You can read more about X.25 at <http://www.sangoma.com/tutorials/x=
25/> and
+	  <http://docwiki.cisco.com/wiki/X.25>.
 	  Information about X.25 for Linux is contained in the files
 	  <file:Documentation/networking/x25.txt> and
 	  <file:Documentation/networking/x25-iface.txt>.
--=20
1.8.3.1
