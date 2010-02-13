From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next 0/7] Add netdev_printk and netif_printk
 macros
Date: Fri, 12 Feb 2010 20:40:44 -0800 (PST)
Message-ID: <20100212.204044.38063904.davem@davemloft.net>
References: <20100212.123129.163263355.davem@davemloft.net>
	<20100212.131004.197405614.davem@davemloft.net>
	<1266034336.14805.84.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34050
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753328Ab0BMEka (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2010 23:40:30 -0500
In-Reply-To: <1266034336.14805.84.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Fri, 12 Feb 2010 20:12:16 -0800

> If you want to take the RFC patches, OK, but I could send
> a patchset that compiles all cases cleanly.  Want that?

I've already fixed things up (by changing the arg in these macros to
"__dev") and pushed it out to net-next-2.6
