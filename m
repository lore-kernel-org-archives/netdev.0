From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCHSET] IPv6 address configuration conversions
Date: Fri, 01 Sep 2006 23:39:57 +0200
Message-ID: <20060901213957.138695086@lsx.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:64400 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1750956AbWIAVlI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2006 17:41:08 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Converts all of the IPv6 address configuration code to the new
netlink api and removes a bogus check on IFF_UP when adding
new addresses.


-- 
VGER BF report: U 0.467674
