From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: NMI lockup, 2.6.26 release
Date: Sat, 2 Aug 2008 15:07:40 +0200
Message-ID: <20080802130740.GA2970@ami.dom.local>
References: <200807222142.23710.denys@visp.net.lb> <200807240256.36098.denys@visp.net.lb> <20080725073628.GA10399@ff.dom.local> <200808021555.10733.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.179]:28287 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756087AbYHBNG2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Aug 2008 09:06:28 -0400
Received: by ik-out-1112.google.com with SMTP id c28so1632468ika.5
        for <netdev@vger.kernel.org>; Sat, 02 Aug 2008 06:06:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200808021555.10733.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 02, 2008 at 03:55:10PM +0300, Denys Fedoryshchenko wrote:
> Sorry for long delay, i had to make sure that old change "fixed" the problem.
> 
> Now i am running second patch, it will take also around up to one week to make 
> sure, that it is also make (or doesn't make) any changes, because sometimes 
> it takes 3-4 days till crash happen.

OK, don't hurry!

Cheers,
Jarek P.

> 
> On Friday 25 July 2008, Jarek Poplawski wrote:
> > Hi Denys,
> >
> > In case this is still working after hrtimer -> timer change here is
> > another patch for testing: to check if limiting hrtimers scheduling
> > could matter here. Btw. could you write what is the approximate
> > number of htb qdiscs and classes working on each device of this box
> > (including ifbs)?
> >
> > Thanks,
> > Jarek P.
