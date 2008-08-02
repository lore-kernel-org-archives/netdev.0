From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: NMI lockup, 2.6.26 release
Date: Sat, 2 Aug 2008 15:55:10 +0300
Message-ID: <200808021555.10733.denys@visp.net.lb>
References: <200807222142.23710.denys@visp.net.lb> <200807240256.36098.denys@visp.net.lb> <20080725073628.GA10399@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:50934 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752688AbYHBMzp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Aug 2008 08:55:45 -0400
In-Reply-To: <20080725073628.GA10399@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry for long delay, i had to make sure that old change "fixed" the problem.

Now i am running second patch, it will take also around up to one week to make 
sure, that it is also make (or doesn't make) any changes, because sometimes 
it takes 3-4 days till crash happen.

On Friday 25 July 2008, Jarek Poplawski wrote:
> Hi Denys,
>
> In case this is still working after hrtimer -> timer change here is
> another patch for testing: to check if limiting hrtimers scheduling
> could matter here. Btw. could you write what is the approximate
> number of htb qdiscs and classes working on each device of this box
> (including ifbs)?
>
> Thanks,
> Jarek P.
