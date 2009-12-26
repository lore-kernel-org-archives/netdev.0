From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v2] llc enhancements
Date: Fri, 25 Dec 2009 17:11:55 -0800 (PST)
Message-ID: <20091225.171155.226760487.davem@davemloft.net>
References: <1261611934-24348-1-git-send-email-opurdila@ixiacom.com>
	<4B3327D3.7080704@gmail.com>
	<200912241417.03003.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	acme@ghostprotocols.net
To: opurdila@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37916
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752122AbZLZBLx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Dec 2009 20:11:53 -0500
In-Reply-To: <200912241417.03003.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <opurdila@ixiacom.com>
Date: Thu, 24 Dec 2009 14:17:02 +0200

> But, I found a leak issue: if the sap check fails we should sock_put
> the socket before trying again !

Octavian, please resubmit your patch series after you've
sorted out these issues/leaks/etc.

Thanks a lot!
