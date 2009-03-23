From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] Re: TCP/IP stack interpretation of
 acceptable packet
Date: Mon, 23 Mar 2009 11:58:21 -0700 (PDT)
Message-ID: <20090323.115821.67647014.davem@davemloft.net>
References: <1237423493.32009.31.camel@Maple>
	<20090322.215033.192091282.davem@davemloft.net>
	<20090323122806.GA11935@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.dykstra1@gmail.com, mailinglists+netdev@oliverzheng.com,
	netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60578
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753645AbZCWS6d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 14:58:33 -0400
In-Reply-To: <20090323122806.GA11935@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Mon, 23 Mar 2009 13:28:06 +0100

> > I've been mulling over this patch for more than a week :-)
> > 
> > Let's put this into net-next-2.6 and let it cook there for
> > a while.  It is possible I'll backport this into -stable
> > after some time.
> 
> One thing that might be useful for the testing period would 
> be explicit printk when such a new discard happens? Otherwise
> it would be difficult to find out if something really goes wrong.

No, thanks.
