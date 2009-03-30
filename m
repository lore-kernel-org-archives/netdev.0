From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: [PATCH 1/3] Doc: Fix missing whitespaces in RCU documentation.
Date: Mon, 30 Mar 2009 11:02:56 +0200
Message-ID: <20090330090256.19172.49973.stgit@localhost.localdomain>
References: <20090330085302.19172.22808.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:40327 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758069AbZC3JC6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2009 05:02:58 -0400
In-Reply-To: <20090330085302.19172.22808.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Trivial fix while reading through the RCU docs.

Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---

 Documentation/RCU/rcu.txt |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/Documentation/RCU/rcu.txt b/Documentation/RCU/rcu.txt
index 95821a2..7aa2002 100644
--- a/Documentation/RCU/rcu.txt
+++ b/Documentation/RCU/rcu.txt
@@ -81,7 +81,7 @@ o	I hear that RCU needs work in order to support realtime kernels?
 	This work is largely completed.  Realtime-friendly RCU can be
 	enabled via the CONFIG_PREEMPT_RCU kernel configuration parameter.
 	However, work is in progress for enabling priority boosting of
-	preempted RCU read-side critical sections.This is needed if you
+	preempted RCU read-side critical sections.  This is needed if you
 	have CPU-bound realtime threads.
 
 o	Where can I find more information on RCU?

