From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] tipc: spelling fixes
Date: Sun, 12 Jan 2014 12:48:00 -0800
Message-ID: <20140112124800.6cf8d786@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jon Maloy <jon.maloy@ericsson.com>,
	Allan Stephens <allan.stephens@windriver.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:60680 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751019AbaALUsG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jan 2014 15:48:06 -0500
Received: by mail-pd0-f180.google.com with SMTP id q10so6597630pdj.25
        for <netdev@vger.kernel.org>; Sun, 12 Jan 2014 12:48:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/net/tipc/bearer.c	2014-01-09 22:16:13.794077217 -0800
+++ b/net/tipc/bearer.c	2014-01-12 10:31:12.583133108 -0800
@@ -473,7 +473,7 @@ void tipc_disable_l2_media(struct tipc_b
 /**
  * tipc_l2_send_msg - send a TIPC packet out over an Ethernet interface
  * @buf: the packet to be sent
- * @b_ptr: the bearer throught which the packet is to be sent
+ * @b_ptr: the bearer through which the packet is to be sent
  * @dest: peer destination address
  */
 int tipc_l2_send_msg(struct sk_buff *buf, struct tipc_bearer *b,
--- a/net/tipc/server.c	2013-12-31 17:45:31.689947239 -0800
+++ b/net/tipc/server.c	2014-01-12 10:31:27.950974631 -0800
@@ -55,7 +55,7 @@
  * @usr_data: user-specified field
  * @rx_action: what to do when connection socket is active
  * @outqueue: pointer to first outbound message in queue
- * @outqueue_lock: controll access to the outqueue
+ * @outqueue_lock: control access to the outqueue
  * @outqueue: list of connection objects for its server
  * @swork: send work item
  */
--- a/net/tipc/subscr.c	2013-12-31 17:45:31.661947637 -0800
+++ b/net/tipc/subscr.c	2014-01-12 10:30:56.830292389 -0800
@@ -42,7 +42,7 @@
 /**
  * struct tipc_subscriber - TIPC network topology subscriber
  * @conid: connection identifier to server connecting to subscriber
- * @lock: controll access to subscriber
+ * @lock: control access to subscriber
  * @subscription_list: list of subscription objects for this subscriber
  */
 struct tipc_subscriber {
