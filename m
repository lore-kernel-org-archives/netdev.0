From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] tc: comment spelling fixes
Date: Mon, 21 Nov 2011 08:53:46 -0800
Message-ID: <20111121085346.2203c4f4@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44446 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752496Ab1KUQxx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Nov 2011 11:53:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/include/linux/pkt_sched.h	2011-11-09 13:54:59.780009551 -0800
+++ b/include/linux/pkt_sched.h	2011-11-21 08:51:20.062228855 -0800
@@ -30,7 +30,7 @@
  */
 
 struct tc_stats {
-	__u64	bytes;			/* NUmber of enqueues bytes */
+	__u64	bytes;			/* Number of enqueues bytes */
 	__u32	packets;		/* Number of enqueued packets	*/
 	__u32	drops;			/* Packets dropped because of lack of resources */
 	__u32	overlimits;		/* Number of throttle events when this
@@ -297,7 +297,7 @@ struct tc_htb_glob {
 	__u32 debug;		/* debug flags */
 
 	/* stats */
-	__u32 direct_pkts; /* count of non shapped packets */
+	__u32 direct_pkts; /* count of non shaped packets */
 };
 enum {
 	TCA_HTB_UNSPEC,
@@ -503,7 +503,7 @@ enum {
 };
 #define NETEM_LOSS_MAX (__NETEM_LOSS_MAX - 1)
 
-/* State transition probablities for 4 state model */
+/* State transition probabilities for 4 state model */
 struct tc_netem_gimodel {
 	__u32	p13;
 	__u32	p31;
