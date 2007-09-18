From: David Miller <davem@davemloft.net>
Subject: Re: [0/3] [PPP]: Fix pppol2tp skb bugs
Date: Tue, 18 Sep 2007 13:17:47 -0700 (PDT)
Message-ID: <20070918.131747.01290534.davem@davemloft.net>
References: <46D69323.3070503@katalix.com>
	<20070831090625.GA28175@gondor.apana.org.au>
	<20070918120438.GA9121@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jchapman@katalix.com, mostrows@speakeasy.net, paulus@samba.org,
	toralf.foerster@gmx.de, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59164
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752411AbXIRUR6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 16:17:58 -0400
In-Reply-To: <20070918120438.GA9121@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 18 Sep 2007 20:04:38 +0800

> On Fri, Aug 31, 2007 at 05:06:25PM +0800, Herbert Xu wrote:
> > 
> > I've audited ppp_generic.c and pppoe.c.  I'll do pppol2tp
> > tomorrow.
> 
> Tomrrow took a while to come :)

It took me two weeks to apply the original patch set so you
get a reprieve too :-)

> Here are the fixes for pppol2tp.

I'll apply these, thanks Herbert.
