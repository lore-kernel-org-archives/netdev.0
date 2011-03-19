From: =?UTF-8?q?Nicolas=20de=20Peslo=C3=BCan?=
	<nicolas.2p.debian@free.fr>
Subject: [PATCH] bonding: fix a typo in a comment
Date: Sat, 19 Mar 2011 14:31:07 +0100
Message-ID: <1300541467-6133-1-git-send-email-nicolas.2p.debian@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fubar@us.ibm.com, andy@greyhouse.net, netdev@vger.kernel.org,
	=?UTF-8?q?Nicolas=20de=20Peslo=C3=BCan?=
	<nicolas.2p.debian@free.fr>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g21.free.fr ([212.27.42.6]:52502 "EHLO smtp6-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751481Ab1CSNbm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Mar 2011 09:31:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nicolas de Peslo=C3=BCan <nicolas.2p.debian@free.fr>
---
 drivers/net/bonding/bond_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index 1a6e9eb..338bea1 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2130,7 +2130,7 @@ int bond_release(struct net_device *bond_dev, str=
uct net_device *slave_dev)
 }
=20
 /*
-* First release a slave and than destroy the bond if no more slaves ar=
e left.
+* First release a slave and then destroy the bond if no more slaves ar=
e left.
 * Must be under rtnl_lock when this function is called.
 */
 static int  bond_release_and_destroy(struct net_device *bond_dev,
--=20
1.7.4.1

