From: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 3/3] trivial: fix typo in ieee802154
	documentation and add it to index
Date: Mon, 27 Jul 2009 18:08:15 +0400
Message-ID: <1248703695-7043-4-git-send-email-dbaryshkov@gmail.com>
References: <1248703695-7043-1-git-send-email-dbaryshkov@gmail.com>
	<1248703695-7043-2-git-send-email-dbaryshkov@gmail.com>
	<1248703695-7043-3-git-send-email-dbaryshkov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	Thadeu Lima de Souza Cascardo <cascardo-DmMZpsCg3uxeGPcbtGPokg@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1248703695-7043-3-git-send-email-dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Thadeu Lima de Souza Cascardo <cascardo-DmMZpsCg3uxeGPcbtGPokg@public.gmane.org>

Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo-DmMZpsCg3uxeGPcbtGPokg@public.gmane.org>
---
 Documentation/networking/00-INDEX       |    2 ++
 Documentation/networking/ieee802154.txt |    2 +-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/Documentation/networking/00-INDEX b/Documentation/networking/00-INDEX
index 1634c6d..50189bf 100644
--- a/Documentation/networking/00-INDEX
+++ b/Documentation/networking/00-INDEX
@@ -60,6 +60,8 @@ framerelay.txt
 	- info on using Frame Relay/Data Link Connection Identifier (DLCI).
 generic_netlink.txt
 	- info on Generic Netlink
+ieee802154.txt
+	- Linux IEEE 802.15.4 implementation, API and drivers
 ip-sysctl.txt
 	- /proc/sys/net/ipv4/* variables
 ip_dynaddr.txt
diff --git a/Documentation/networking/ieee802154.txt b/Documentation/networking/ieee802154.txt
index a0280ad..1d4ed66 100644
--- a/Documentation/networking/ieee802154.txt
+++ b/Documentation/networking/ieee802154.txt
@@ -69,7 +69,7 @@ We provide an example of simple HardMAC driver at drivers/ieee802154/fakehard.c
 SoftMAC
 =======
 
-We are going to provide intermediate layer impelementing IEEE 802.15.4 MAC
+We are going to provide intermediate layer implementing IEEE 802.15.4 MAC
 in software. This is currently WIP.
 
 See header include/net/ieee802154/mac802154.h and several drivers in
-- 
1.6.3.3


------------------------------------------------------------------------------
