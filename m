From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH[ depca: remove double semi-colon
Date: Sun, 25 Jan 2004 16:56:33 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040125165633.2660c082.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Please apply to 2.6.current.

--
~Randy


description:      remove double semi-colon typo;

diffstat:=
 drivers/net/depca.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -Naurp ./drivers/net/depca.c~depca_semi ./drivers/net/depca.c
--- ./drivers/net/depca.c~depca_semi	2004-01-08 22:59:42.000000000 -0800
+++ ./drivers/net/depca.c	2004-01-25 16:48:45.000000000 -0800
@@ -1459,7 +1459,7 @@ static int __init depca_mca_probe(struct
  out_unclaim:
 	mca_device_set_claim(mdev, 0);
 
-	return err;;
+	return err;
 }
 #endif
 
