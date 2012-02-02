From: David Miller <davem@davemloft.net>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at
 000000000000002c
Date: Thu, 02 Feb 2012 14:39:57 -0500 (EST)
Message-ID: <20120202.143957.2251106530056768980.davem@davemloft.net>
References: <20120201.162157.880976652659067010.davem@davemloft.net>
	<4F2A87B0.6070900@profihost.ag>
	<1328195055.2279.61.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: s.priebe@profihost.ag, greg@kroah.com, jwboyer@gmail.com,
	hch@infradead.org, netdev@vger.kernel.org, david@fromorbit.com,
	stable@vger.kernel.org, gregkh@suse.de
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44967 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756074Ab2BBTlX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 14:41:23 -0500
In-Reply-To: <1328195055.2279.61.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 02 Feb 2012 16:04:15 +0100

> David, what do you think ?

I frankly don't care at this point.

The only reasonable thing is if someone can successfully do the
backport, but if that's not possible there really isn't anything
reasonable we can do, all the other options have fatal negative
consequences which make them completely untenable.
