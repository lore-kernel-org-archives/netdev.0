From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] IPV6 address management
Date: Thu, 08 Jan 2009 14:03:39 -0800 (PST)
Message-ID: <20090108.140339.00980764.davem@davemloft.net>
References: <20090108135614.23aed603@extreme>
	<20090108.135819.103389689.davem@davemloft.net>
	<20090108140122.5488d84c@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36088
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754746AbZAHWDi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 17:03:38 -0500
In-Reply-To: <20090108140122.5488d84c@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 8 Jan 2009 14:01:22 -0800

> Fine, it won't be the first or last vendor specific kernel patch.

You're just supporting my argument even more.

If all the dists ship it and turn it on, then logically we should
include it and have it on by default.

But you know we can't do that.

Therefore, it's detrimental for the dists to ship it too because it
does break things.

I know you want to shove this in, via some avenue, but it is really
so undesirable to cope with existing behavior?
