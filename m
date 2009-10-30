From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] sky2: driver update
Date: Thu, 29 Oct 2009 22:53:33 -0700 (PDT)
Message-ID: <20091029.225333.237745260.davem@davemloft.net>
References: <20091029163704.793246334@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49101
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754731AbZJ3FxJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 01:53:09 -0400
In-Reply-To: <20091029163704.793246334@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 29 Oct 2009 09:37:04 -0700

> This patch set adds support for Yukon Optima (88E8059) based
> on the vendor driver.  Hopefully, it can go in 2.6.32.

Sorry, this is too much too late.  You don't even have the hardware
to test the changes you are making to the driver which makes this
even more questionable for net-2.6

I'll toss this into net-next-2.6 and let's let it cook there for
a while at least.

If you want to pick out a small bug fix or two from this series
for net-2.6, please feel free to resubmit them specifically for
net-2.6 inclusion.

Thanks.
