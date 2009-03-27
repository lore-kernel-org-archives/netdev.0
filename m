From: David Miller <davem@davemloft.net>
Subject: Re: net-2.6 being rebased...
Date: Fri, 27 Mar 2009 15:39:39 -0700 (PDT)
Message-ID: <20090327.153939.188543326.davem@davemloft.net>
References: <20090327.151151.203275323.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59387
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752239AbZC0Wjw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 18:39:52 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id D8DCCC8C1AC
	for <netdev@vger.kernel.org>; Fri, 27 Mar 2009 15:39:39 -0700 (PDT)
In-Reply-To: <20090327.151151.203275323.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Fri, 27 Mar 2009 15:11:51 -0700 (PDT)

> 
> I have to do this to get rid of the ax25/netrom changes from Alan I
> applied yesterday.
> 
> Better to do it now on new trees rather than ones that have been in
> use and propagated for months, right? :-)
> 
> Again, sorry for any inconvenience this may cause.

It actually turned out that I didn't need to rebase, Alan was
talking about some other older patches he objected to.

I blew away the master.kernel.org trees before I figured that out.

However I think I rebuilt them in such a way that you can still
pull cleanly from them if you had the tree that was there before.

Let me know if there are any problems, sorry for all the confusion.
