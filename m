From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v4] fib_rules: add .suppress operation
Date: Thu, 1 Aug 2013 07:35:12 +0200
Message-ID: <20130801053512.GB3688@order.stressinduktion.org>
References: <20130727070758.GA23904@order.stressinduktion.org> <20130801001715.GA27283@zirkel.wertarbyte.de> <20130731.172740.549970338016485006.davem@davemloft.net> <20130801012621.GM10550@zirkel.wertarbyte.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	bsderandrew@gmail.com
To: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:52703 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751246Ab3HAFfN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 01:35:13 -0400
Content-Disposition: inline
In-Reply-To: <20130801012621.GM10550@zirkel.wertarbyte.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 01, 2013 at 03:26:21AM +0200, Stefan Tomanek wrote:
> Dies schrieb David Miller (davem@davemloft.net):
> 
> > Applied, thanks.
> 
> Thank you very much; Hannes Frederic Sowa noted some irregularities with the
> error reporting in fib6_rules (message ID
> <20130727060802.GD20273@order.stressinduktion.org>) that might interfere with
> the function of my patch; perhaps his change should be applied as well?  I've
> reposted his changes with git format-patch as message ID
> <20130730065258.GG13357@zirkel.wertarbyte.de> ("[PATCH v2 1/2] fib6_rules: make
> error handling consistent with IPv4").

I can take care of this and will repost the patch today.

Thank you,

  Hannes
