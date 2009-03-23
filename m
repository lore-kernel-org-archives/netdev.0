From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH net-next-2.6] Re: TCP/IP stack interpretation of acceptable packet
Date: Mon, 23 Mar 2009 13:28:06 +0100
Message-ID: <20090323122806.GA11935@one.firstfloor.org>
References: <2ff60cd60902241459q1de39054lb3dc5233f13b69c3@mail.gmail.com> <1237423493.32009.31.camel@Maple> <20090322.215033.192091282.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: john.dykstra1@gmail.com, mailinglists+netdev@oliverzheng.com,
	netdev@vger.kernel.org, andi@firstfloor.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:48155 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751898AbZCWM1T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 08:27:19 -0400
Content-Disposition: inline
In-Reply-To: <20090322.215033.192091282.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I've been mulling over this patch for more than a week :-)
> 
> Let's put this into net-next-2.6 and let it cook there for
> a while.  It is possible I'll backport this into -stable
> after some time.

One thing that might be useful for the testing period would 
be explicit printk when such a new discard happens? Otherwise
it would be difficult to find out if something really goes wrong.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
