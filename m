From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 02/18] batman-adv: update email address for Simon Wunderlich
Date: Sun, 20 Oct 2013 00:21:54 +0200
Message-ID: <1382221330-3769-3-git-send-email-antonio@meshcoding.com>
References: <1382221330-3769-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <sw@simonwunderlich.de>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:24898 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752418Ab3JSWW6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Oct 2013 18:22:58 -0400
In-Reply-To: <1382221330-3769-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <sw@simonwunderlich.de>

My university will stop email service for alumni in january 2014, please
use my new e-mail address instead.

Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 Documentation/ABI/testing/sysfs-class-net-mesh | 4 ++--
 Documentation/networking/batman-adv.txt        | 2 +-
 MAINTAINERS                                    | 2 +-
 net/batman-adv/main.h                          | 2 +-
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/Documentation/ABI/testing/sysfs-class-net-mesh b/Documentation/ABI/testing/sysfs-class-net-mesh
index f00a69b..96ae0a4 100644
--- a/Documentation/ABI/testing/sysfs-class-net-mesh
+++ b/Documentation/ABI/testing/sysfs-class-net-mesh
@@ -16,7 +16,7 @@ Description:
 
 What:           /sys/class/net/<mesh_iface>/mesh/bonding
 Date:           June 2010
-Contact:        Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
+Contact:        Simon Wunderlich <sw@simonwunderlich.de>
 Description:
                 Indicates whether the data traffic going through the
                 mesh will be sent using multiple interfaces at the
@@ -24,7 +24,7 @@ Description:
 
 What:           /sys/class/net/<mesh_iface>/mesh/bridge_loop_avoidance
 Date:           November 2011
-Contact:        Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
+Contact:        Simon Wunderlich <sw@simonwunderlich.de>
 Description:
                 Indicates whether the bridge loop avoidance feature
                 is enabled. This feature detects and avoids loops
diff --git a/Documentation/networking/batman-adv.txt b/Documentation/networking/batman-adv.txt
index 897d1f4..89ace66 100644
--- a/Documentation/networking/batman-adv.txt
+++ b/Documentation/networking/batman-adv.txt
@@ -200,4 +200,4 @@ Mailing-list:   b.a.t.m.a.n@open-mesh.org (optional  subscription
 You can also contact the Authors:
 
 Marek  Lindner  <lindner_marek@yahoo.de>
-Simon  Wunderlich  <siwu@hrz.tu-chemnitz.de>
+Simon  Wunderlich  <sw@simonwunderlich.de>
diff --git a/MAINTAINERS b/MAINTAINERS
index a46bcf81..f169259 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1653,7 +1653,7 @@ F:	include/linux/backlight.h
 
 BATMAN ADVANCED
 M:	Marek Lindner <mareklindner@neomailbox.ch>
-M:	Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
+M:	Simon Wunderlich <sw@simonwunderlich.de>
 M:	Antonio Quartulli <antonio@meshcoding.com>
 L:	b.a.t.m.a.n@lists.open-mesh.org
 W:	http://www.open-mesh.org/
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 54c13d5..c754f8e 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -21,7 +21,7 @@
 #define _NET_BATMAN_ADV_MAIN_H_
 
 #define BATADV_DRIVER_AUTHOR "Marek Lindner <lindner_marek@yahoo.de>, " \
-			     "Simon Wunderlich <siwu@hrz.tu-chemnitz.de>"
+			     "Simon Wunderlich <sw@simonwunderlich.de>"
 #define BATADV_DRIVER_DESC   "B.A.T.M.A.N. advanced"
 #define BATADV_DRIVER_DEVICE "batman-adv"
 
-- 
1.8.4
