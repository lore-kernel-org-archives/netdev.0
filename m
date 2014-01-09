From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 03/13] batman-adv: remove FSF address from GPL disclaimer
Date: Thu,  9 Jan 2014 15:52:52 +0100
Message-ID: <1389279182-3256-4-git-send-email-antonio@meshcoding.com>
References: <1389279182-3256-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@meshcoding.com>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:2629 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752540AbaAIOyd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 09:54:33 -0500
In-Reply-To: <1389279182-3256-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As suggested by checkpatch, remove all the references to the
FSF address since the kernel already has one reference in
its documentation.

In this way it is easier to update it in case of future
changes.

Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/Makefile                | 4 +---
 net/batman-adv/bat_algo.h              | 4 +---
 net/batman-adv/bat_iv_ogm.c            | 4 +---
 net/batman-adv/bitarray.c              | 4 +---
 net/batman-adv/bitarray.h              | 4 +---
 net/batman-adv/bridge_loop_avoidance.c | 4 +---
 net/batman-adv/bridge_loop_avoidance.h | 4 +---
 net/batman-adv/debugfs.c               | 4 +---
 net/batman-adv/debugfs.h               | 4 +---
 net/batman-adv/distributed-arp-table.c | 4 +---
 net/batman-adv/distributed-arp-table.h | 4 +---
 net/batman-adv/fragmentation.c         | 4 +---
 net/batman-adv/fragmentation.h         | 4 +---
 net/batman-adv/gateway_client.c        | 4 +---
 net/batman-adv/gateway_client.h        | 4 +---
 net/batman-adv/gateway_common.c        | 4 +---
 net/batman-adv/gateway_common.h        | 4 +---
 net/batman-adv/hard-interface.c        | 4 +---
 net/batman-adv/hard-interface.h        | 4 +---
 net/batman-adv/hash.c                  | 4 +---
 net/batman-adv/hash.h                  | 4 +---
 net/batman-adv/icmp_socket.c           | 4 +---
 net/batman-adv/icmp_socket.h           | 4 +---
 net/batman-adv/main.c                  | 4 +---
 net/batman-adv/main.h                  | 4 +---
 net/batman-adv/network-coding.c        | 4 +---
 net/batman-adv/network-coding.h        | 4 +---
 net/batman-adv/originator.c            | 4 +---
 net/batman-adv/originator.h            | 4 +---
 net/batman-adv/packet.h                | 4 +---
 net/batman-adv/routing.c               | 4 +---
 net/batman-adv/routing.h               | 4 +---
 net/batman-adv/send.c                  | 4 +---
 net/batman-adv/send.h                  | 4 +---
 net/batman-adv/soft-interface.c        | 4 +---
 net/batman-adv/soft-interface.h        | 4 +---
 net/batman-adv/sysfs.c                 | 4 +---
 net/batman-adv/sysfs.h                 | 4 +---
 net/batman-adv/translation-table.c     | 4 +---
 net/batman-adv/translation-table.h     | 4 +---
 net/batman-adv/types.h                 | 4 +---
 41 files changed, 41 insertions(+), 123 deletions(-)

diff --git a/net/batman-adv/Makefile b/net/batman-adv/Makefile
index 4f4aabb..e595415 100644
--- a/net/batman-adv/Makefile
+++ b/net/batman-adv/Makefile
@@ -13,9 +13,7 @@
 # General Public License for more details.
 #
 # You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software
-# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
-# 02110-1301, USA
+# along with this program; if not, see <http://www.gnu.org/licenses/>.
 #
 
 obj-$(CONFIG_BATMAN_ADV) += batman-adv.o
diff --git a/net/batman-adv/bat_algo.h b/net/batman-adv/bat_algo.h
index a4808c2..92435bf 100644
--- a/net/batman-adv/bat_algo.h
+++ b/net/batman-adv/bat_algo.h
@@ -12,9 +12,7 @@
  * General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #ifndef _NET_BATMAN_ADV_BAT_ALGO_H_
diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index b9c8a6e..278d78b 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -12,9 +12,7 @@
  * General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include "main.h"
diff --git a/net/batman-adv/bitarray.c b/net/batman-adv/bitarray.c
index 9739824..89d3a5b 100644
--- a/net/batman-adv/bitarray.c
+++ b/net/batman-adv/bitarray.c
@@ -12,9 +12,7 @@
  * General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include "main.h"
diff --git a/net/batman-adv/bitarray.h b/net/batman-adv/bitarray.h
index a81b932..685e0af 100644
--- a/net/batman-adv/bitarray.h
+++ b/net/batman-adv/bitarray.h
@@ -12,9 +12,7 @@
  * General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #ifndef _NET_BATMAN_ADV_BITARRAY_H_
diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 28eb5e6..b164a07 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -12,9 +12,7 @@
  * General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include "main.h"
diff --git a/net/batman-adv/bridge_loop_avoidance.h b/net/batman-adv/bridge_loop_avoidance.h
index da173e7..377dae0 100644
--- a/net/batman-adv/bridge_loop_avoidance.h
+++ b/net/batman-adv/bridge_loop_avoidance.h
@@ -12,9 +12,7 @@
  * General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #ifndef _NET_BATMAN_ADV_BLA_H_
diff --git a/net/batman-adv/debugfs.c b/net/batman-adv/debugfs.c
index 049a7a2..0adbcee 100644
--- a/net/batman-adv/debugfs.c
+++ b/net/batman-adv/debugfs.c
@@ -12,9 +12,7 @@
  * General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include "main.h"
diff --git a/net/batman-adv/debugfs.h b/net/batman-adv/debugfs.h
index f8c3849..0861b62 100644
--- a/net/batman-adv/debugfs.h
+++ b/net/batman-adv/debugfs.h
@@ -12,9 +12,7 @@
  * General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #ifndef _NET_BATMAN_ADV_DEBUGFS_H_
diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index b316a4c..01ec607 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -12,9 +12,7 @@
  * General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include <linux/if_ether.h>
diff --git a/net/batman-adv/distributed-arp-table.h b/net/batman-adv/distributed-arp-table.h
index 79a078b..afa13ca 100644
--- a/net/batman-adv/distributed-arp-table.h
+++ b/net/batman-adv/distributed-arp-table.h
@@ -12,9 +12,7 @@
  * General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #ifndef _NET_BATMAN_ADV_DISTRIBUTED_ARP_TABLE_H_
diff --git a/net/batman-adv/fragmentation.c b/net/batman-adv/fragmentation.c
index 6ddb614..43185ca 100644
--- a/net/batman-adv/fragmentation.c
+++ b/net/batman-adv/fragmentation.c
@@ -12,9 +12,7 @@
  * General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include "main.h"
diff --git a/net/batman-adv/fragmentation.h b/net/batman-adv/fragmentation.h
index ca029e2..0347f0c 100644
--- a/net/batman-adv/fragmentation.h
+++ b/net/batman-adv/fragmentation.h
@@ -12,9 +12,7 @@
  * General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #ifndef _NET_BATMAN_ADV_FRAGMENTATION_H_
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 2449afa..3564173 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -12,9 +12,7 @@
  * General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include "main.h"
diff --git a/net/batman-adv/gateway_client.h b/net/batman-adv/gateway_client.h
index d95c2d2..43c8833 100644
--- a/net/batman-adv/gateway_client.h
+++ b/net/batman-adv/gateway_client.h
@@ -12,9 +12,7 @@
  * General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #ifndef _NET_BATMAN_ADV_GATEWAY_CLIENT_H_
diff --git a/net/batman-adv/gateway_common.c b/net/batman-adv/gateway_common.c
index b211b0f..5e63b81 100644
--- a/net/batman-adv/gateway_common.c
+++ b/net/batman-adv/gateway_common.c
@@ -12,9 +12,7 @@
  * General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include "main.h"
diff --git a/net/batman-adv/gateway_common.h b/net/batman-adv/gateway_common.h
index 56384a4..c47b17a 100644
--- a/net/batman-adv/gateway_common.h
+++ b/net/batman-adv/gateway_common.h
@@ -12,9 +12,7 @@
  * General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #ifndef _NET_BATMAN_ADV_GATEWAY_COMMON_H_
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 57c2a19..bebd46ce 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -12,9 +12,7 @@
  * General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include "main.h"
diff --git a/net/batman-adv/hard-interface.h b/net/batman-adv/hard-interface.h
index df4c8bd..d8ca8ac 100644
--- a/net/batman-adv/hard-interface.h
+++ b/net/batman-adv/hard-interface.h
@@ -12,9 +12,7 @@
  * General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #ifndef _NET_BATMAN_ADV_HARD_INTERFACE_H_
diff --git a/net/batman-adv/hash.c b/net/batman-adv/hash.c
index 7198daf..d9cfa03 100644
--- a/net/batman-adv/hash.c
+++ b/net/batman-adv/hash.c
@@ -12,9 +12,7 @@
  * General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include "main.h"
diff --git a/net/batman-adv/hash.h b/net/batman-adv/hash.h
index 1b4da72..df5ece9 100644
--- a/net/batman-adv/hash.h
+++ b/net/batman-adv/hash.h
@@ -12,9 +12,7 @@
  * General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #ifndef _NET_BATMAN_ADV_HASH_H_
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index 130cc32..3c08eee 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -12,9 +12,7 @@
  * General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include "main.h"
diff --git a/net/batman-adv/icmp_socket.h b/net/batman-adv/icmp_socket.h
index 6665080..559e54a 100644
--- a/net/batman-adv/icmp_socket.h
+++ b/net/batman-adv/icmp_socket.h
@@ -12,9 +12,7 @@
  * General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #ifndef _NET_BATMAN_ADV_ICMP_SOCKET_H_
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 1511f64..8abda42 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -12,9 +12,7 @@
  * General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include <linux/crc32c.h>
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 322dd73..9e76b6c 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -12,9 +12,7 @@
  * General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #ifndef _NET_BATMAN_ADV_MAIN_H_
diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-coding.c
index 511d7e1..d6f0be3 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -12,9 +12,7 @@
  * General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include <linux/debugfs.h>
diff --git a/net/batman-adv/network-coding.h b/net/batman-adv/network-coding.h
index d4fd315..ab59b3d 100644
--- a/net/batman-adv/network-coding.h
+++ b/net/batman-adv/network-coding.h
@@ -12,9 +12,7 @@
  * General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #ifndef _NET_BATMAN_ADV_NETWORK_CODING_H_
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 803ab4b..04a6d51 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -12,9 +12,7 @@
  * General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include "main.h"
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
index 6f77d80..99ed3c6 100644
--- a/net/batman-adv/originator.h
+++ b/net/batman-adv/originator.h
@@ -12,9 +12,7 @@
  * General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #ifndef _NET_BATMAN_ADV_ORIGINATOR_H_
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 2dd8f24..5e73294 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -12,9 +12,7 @@
  * General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #ifndef _NET_BATMAN_ADV_PACKET_H_
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index a89e812..7e8aa17 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -12,9 +12,7 @@
  * General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include "main.h"
diff --git a/net/batman-adv/routing.h b/net/batman-adv/routing.h
index 19544dd..c1eadfa 100644
--- a/net/batman-adv/routing.h
+++ b/net/batman-adv/routing.h
@@ -12,9 +12,7 @@
  * General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #ifndef _NET_BATMAN_ADV_ROUTING_H_
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index fba4dcf..cea6578 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -12,9 +12,7 @@
  * General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include "main.h"
diff --git a/net/batman-adv/send.h b/net/batman-adv/send.h
index aa2e253..f6d125e 100644
--- a/net/batman-adv/send.h
+++ b/net/batman-adv/send.h
@@ -12,9 +12,7 @@
  * General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #ifndef _NET_BATMAN_ADV_SEND_H_
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index a8f99d1..3686be7 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -12,9 +12,7 @@
  * General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include "main.h"
diff --git a/net/batman-adv/soft-interface.h b/net/batman-adv/soft-interface.h
index 06fc91f..4ab0167 100644
--- a/net/batman-adv/soft-interface.h
+++ b/net/batman-adv/soft-interface.h
@@ -12,9 +12,7 @@
  * General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #ifndef _NET_BATMAN_ADV_SOFT_INTERFACE_H_
diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index 6335433..e28f951 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -12,9 +12,7 @@
  * General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include "main.h"
diff --git a/net/batman-adv/sysfs.h b/net/batman-adv/sysfs.h
index c7d725d..ed80b72 100644
--- a/net/batman-adv/sysfs.h
+++ b/net/batman-adv/sysfs.h
@@ -12,9 +12,7 @@
  * General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #ifndef _NET_BATMAN_ADV_SYSFS_H_
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 19bc42f..2eaa1e9 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -12,9 +12,7 @@
  * General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include "main.h"
diff --git a/net/batman-adv/translation-table.h b/net/batman-adv/translation-table.h
index 026b1ff..08d9bbe 100644
--- a/net/batman-adv/translation-table.h
+++ b/net/batman-adv/translation-table.h
@@ -12,9 +12,7 @@
  * General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #ifndef _NET_BATMAN_ADV_TRANSLATION_TABLE_H_
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 91dd369..e545ac97 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -12,9 +12,7 @@
  * General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #ifndef _NET_BATMAN_ADV_TYPES_H_
-- 
1.8.5.2
