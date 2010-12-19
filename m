From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: fib6_ifdown cleanup
Date: Sat, 18 Dec 2010 22:02:10 -0800 (PST)
Message-ID: <20101218.220210.59687866.davem@davemloft.net>
References: <20101216194240.2b231449@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34210
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750816Ab0LSGBm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Dec 2010 01:01:42 -0500
In-Reply-To: <20101216194240.2b231449@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 16 Dec 2010 19:42:40 -0800

> Remove (unnecessary) casts to make code cleaner.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
