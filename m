From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC 0/2] Add IPsec virtual tunnel interfaces to IPv6
Date: Tue, 20 Aug 2013 17:28:18 -0700 (PDT)
Message-ID: <20130820.172818.250551538126757372.davem@davemloft.net>
References: <20130819062623.GN26773@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49368 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751449Ab3HUA2T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 20:28:19 -0400
In-Reply-To: <20130819062623.GN26773@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Mon, 19 Aug 2013 08:26:23 +0200

> This patchset adds support for IPsec virtual tunnel interfaces to IPv6.
> 
> IPsec virtual tunnel interfaces provide a routable interface for IPsec
> tunnel endpoints. This does not add any tunnel headers, it uses the
> generic xfrm tunneling. It just provides an interface for xfrm IPv6
> tunnels, like the IPv4 side does.
> 
> It has not much testing yet, I can setup the interface and ping through it.
> Review and further testing is very wellcome.
> 
> I'll send the necessary iproute2 patches in a separate thread.

These changes seem well formed to me.
