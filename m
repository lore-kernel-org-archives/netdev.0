From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] netdev: bfin_mac: Remove
 is_multicast_ether_addr use in netdev_for_each_mc_addr
Date: Thu, 13 Jan 2011 21:51:46 -0800 (PST)
Message-ID: <20110113.215146.43434749.davem@davemloft.net>
References: <1294852681.4114.6.camel@Joe-Laptop>
	<20110112.190143.184432859.davem@davemloft.net>
	<1294891685.4114.29.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vapier.adi@gmail.com, tklauser@distanz.ch,
	michael.hennerich@analog.com,
	uclinux-dist-devel@blackfin.uclinux.org, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41218
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752430Ab1ANFvN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 00:51:13 -0500
In-Reply-To: <1294891685.4114.29.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Wed, 12 Jan 2011 20:08:04 -0800

> Remove code that has no effect.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
