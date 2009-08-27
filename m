From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 00/14] pktgen update for net-next (2.6.32)
Date: Thu, 27 Aug 2009 16:55:06 -0700
Message-ID: <20090827235506.624381734@vyatta.com>
Cc: netdev@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>
To: David Miller <davem@davemloft.net>,
	Robert Olsson <robert.olsson@its.uu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58750 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752643AbZH0X7T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Aug 2009 19:59:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The biggest change is switching to monotonic clock (ktime) and
high resolution timers for the interpacket delay.

-- 

