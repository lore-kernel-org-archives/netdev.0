From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: [PATCH] MAINTAINERS: Stephen Hemminger email change
Date: Wed, 16 Jan 2013 09:55:57 -0800
Message-ID: <20130116095557.4775ce5f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Greg KH <greg@kroah.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47423 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755728Ab3APR53 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2013 12:57:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I changed my email because the vyatta.com mail server is now
redirected to brocade.com; and the Brocade mail system
is not friendly to Linux desktop users.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
Please apply to current release (-net) and if allowable put it
in stable to reduce future mail issues.

--- a/MAINTAINERS	2013-01-16 09:46:59.000000000 -0800
+++ b/MAINTAINERS	2013-01-16 09:48:39.622540933 -0800
@@ -2966,7 +2966,7 @@ S:	Maintained
 F:	drivers/net/ethernet/i825xx/eexpress.*
 
 ETHERNET BRIDGE
-M:	Stephen Hemminger <shemminger@vyatta.com>
+M:	Stephen Hemminger <stephen@networkplumber.org>
 L:	bridge@lists.linux-foundation.org
 L:	netdev@vger.kernel.org
 W:	http://www.linuxfoundation.org/en/Net:Bridge
@@ -4906,7 +4906,7 @@ S:	Maintained
 
 MARVELL GIGABIT ETHERNET DRIVERS (skge/sky2)
 M:	Mirko Lindner <mlindner@marvell.com>
-M:	Stephen Hemminger <shemminger@vyatta.com>
+M:	Stephen Hemminger <stephen@networkplumber.org>
 L:	netdev@vger.kernel.org
 S:	Maintained
 F:	drivers/net/ethernet/marvell/sk*
@@ -5181,7 +5181,7 @@ S:	Supported
 F:	drivers/infiniband/hw/nes/
 
 NETEM NETWORK EMULATOR
-M:	Stephen Hemminger <shemminger@vyatta.com>
+M:	Stephen Hemminger <stephen@networkplumber.org>
 L:	netem@lists.linux-foundation.org
 S:	Maintained
 F:	net/sched/sch_netem.c
