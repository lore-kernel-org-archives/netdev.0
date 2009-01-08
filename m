From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] IPV6 address management
Date: Thu, 08 Jan 2009 12:58:30 -0800 (PST)
Message-ID: <20090108.125830.142298950.davem@davemloft.net>
References: <20090108093430.0f966738@extreme>
	<20090108.112420.102641584.davem@davemloft.net>
	<20090108121220.789325a6@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49479
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751557AbZAHU62 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 15:58:28 -0500
In-Reply-To: <20090108121220.789325a6@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 8 Jan 2009 12:12:20 -0800

> What about this?
> 
> If it works (still testing), I'll submit it.

So what is your plan?

Make the routing daemons depend upon the non-default
behavior in order to act correctly?

Or is it to gradually get people to use the non-default
(via distribution sysctl settings etc.) and eventually
make it the default?

I disagree with both plans, and with that the facility
is basically useless.

We absolutely have to live with the behavior we have now,
and for a long time if not forever.
