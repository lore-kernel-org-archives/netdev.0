From: Patrick McHardy <kaber@trash.net>
Subject: [VLAN 16/18]: Update list address
Date: Sun, 20 Jan 2008 18:11:39 +0100 (MET)
Message-ID: <20080120171139.7980.99661.sendpatchset@localhost.localdomain>
References: <20080120171117.7980.67072.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62378 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754538AbYATRLk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 12:11:40 -0500
In-Reply-To: <20080120171117.7980.67072.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[VLAN]: Update list address

VLAN related mail should go to netdev.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit e7e221b07c3a3f77df617232ea0f76094edc1071
tree 347c69877e8e1b5fc5e730b099683739ba83a6d0
parent bea0af04454189d656afd69168e0e3ec3209b6b2
author Patrick McHardy <kaber@trash.net> Sun, 20 Jan 2008 17:37:32 +0100
committer Patrick McHardy <kaber@trash.net> Sun, 20 Jan 2008 17:37:32 +0100

 net/8021q/vlan.c     |    2 +-
 net/8021q/vlan_dev.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 8b93799..dbc81b9 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -3,7 +3,7 @@
  *		Ethernet-type device handling.
  *
  * Authors:	Ben Greear <greearb@candelatech.com>
- *              Please send support related email to: vlan@scry.wanfear.com
+ *              Please send support related email to: netdev@vger.kernel.org
  *              VLAN Home Page: http://www.candelatech.com/~greear/vlan.html
  *
  * Fixes:
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 2ff7659..e19e491 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -3,7 +3,7 @@
  *		Ethernet-type device handling.
  *
  * Authors:	Ben Greear <greearb@candelatech.com>
- *              Please send support related email to: vlan@scry.wanfear.com
+ *              Please send support related email to: netdev@vger.kernel.org
  *              VLAN Home Page: http://www.candelatech.com/~greear/vlan.html
  *
  * Fixes:       Mar 22 2001: Martin Bokaemper <mbokaemper@unispherenetworks.com>
