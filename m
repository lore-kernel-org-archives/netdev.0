From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] openvswitch: kerneldoc warning fix
Date: Wed, 15 Oct 2014 21:03:18 +0200
Message-ID: <1413399798-8514-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	Pravin Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>, dev@openvswitch.org,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

s/sock/gs

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/openvswitch/vport-geneve.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/openvswitch/vport-geneve.c b/net/openvswitch/vport-geneve.c
index 910b3ef..106a9d8 100644
--- a/net/openvswitch/vport-geneve.c
+++ b/net/openvswitch/vport-geneve.c
@@ -30,7 +30,7 @@
 
 /**
  * struct geneve_port - Keeps track of open UDP ports
- * @sock: The socket created for this port number.
+ * @gs: The socket created for this port number.
  * @name: vport name.
  */
 struct geneve_port {
-- 
1.9.3
