From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] IPv6: Add 'autoconf' and 'disable_ipv6' module
 parameters
Date: Mon, 01 Jun 2009 03:08:35 -0700 (PDT)
Message-ID: <20090601.030835.261332360.davem@davemloft.net>
References: <4A204A31.4010105@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org, linux@kolla.no,
	vladislav.yasevich@hp.com
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49659
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754152AbZFAKIf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2009 06:08:35 -0400
In-Reply-To: <4A204A31.4010105@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian Haley <brian.haley@hp.com>
Date: Fri, 29 May 2009 16:48:49 -0400

> Add 'autoconf' and 'disable_ipv6' parameters to the IPv6 module.
> 
> The first controls if IPv6 addresses are autoconfigured from
> prefixes received in Router Advertisements.  The IPv6 loopback
> (::1) and link-local addresses are still configured.
> 
> The second controls if IPv6 addresses are desired at all.  No
> IPv6 addresses will be added to any interfaces.
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>

Applied, but really it is tiring fixing up all of the corruptions
your email client made to this patch.

I've had this problem so many times with you that I've totally
lost any hope that you'll be able to submit patches cleanly and
thus I'm resigned to just fix them up every time from now on. :-/

