From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] uapi: add missing netconf.h to export list
Date: Wed, 12 Dec 2012 08:58:52 -0800
Message-ID: <20121212085852.5b840314@nehalam.linuxnetplumber.net>
References: <1355305907-7102-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49676 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753920Ab2LLRAH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2012 12:00:07 -0500
In-Reply-To: <1355305907-7102-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add netconf.h for use by iproute2.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/include/uapi/linux/Kbuild	2012-10-25 09:11:15.499273810 -0700
+++ b/include/uapi/linux/Kbuild	2012-12-12 08:56:36.130263710 -0800
@@ -258,6 +258,7 @@ header-y += neighbour.h
 header-y += net.h
 header-y += net_dropmon.h
 header-y += net_tstamp.h
+header-y += netconf.h
 header-y += netdevice.h
 header-y += netfilter.h
 header-y += netfilter_arp.h
