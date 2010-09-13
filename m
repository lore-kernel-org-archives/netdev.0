From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 00/10] sfc changes for 2.6.37
Date: Sun, 12 Sep 2010 22:29:04 -0700 (PDT)
Message-ID: <20100912.222904.189705956.davem@davemloft.net>
References: <1284136817.2267.93.camel@achroite.uk.solarflarecom.com>
	<20100910.122854.184831961.davem@davemloft.net>
	<1284148790.2267.322.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41652
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750874Ab0IMF2q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Sep 2010 01:28:46 -0400
In-Reply-To: <1284148790.2267.322.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 10 Sep 2010 20:59:50 +0100

[ talking about standard netdevice statistic meanings ]

> It would really be nice to have more verbose definitions of these in
> rtnetlink.h.  The decider for us was that ifconfig includes
> rx_over_errors in RX frame errors i.e. bad packets.

I completely agree.
