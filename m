From: David Miller <davem@davemloft.net>
Subject: Re: IPv6 DNSSL (rfc6106): please include the patch to pass it to
 user space
Date: Mon, 06 Jun 2011 12:40:10 -0700 (PDT)
Message-ID: <20110606.124010.589373967388745310.davem@davemloft.net>
References: <20080401164904.GA2382@2ka.mipt.ru>
	<20080408122545.GA31729@2ka.mipt.ru>
	<19949.87.934341.698604@fisica.ufpr.br>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: carlos@fisica.ufpr.br
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43148 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753974Ab1FFTkQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 15:40:16 -0400
In-Reply-To: <19949.87.934341.698604@fisica.ufpr.br>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carlos Carvalho <carlos@fisica.ufpr.br>
Date: Mon, 6 Jun 2011 13:29:11 -0300

> Currently the kernel doesn't pass DNSSL lists received by router
> advertsiments (rfc 6106) to user space via netlink. Pierre Ossman sent
> a patch for it about 6 months ago:
> http://patchwork.ozlabs.org/patch/75243. Could you please include it
> in mainline? This is a very useful feature.

The submitter marked that patch as "RFC", he must make a new formal
submission and indicate that it's in a final form and ready to be
actually applied.

You are intelligent enough to find the patch in patchwork, yet you
totally ignore the state that the patch was put into and didn't
even bother considering what it might mean.

What's the point of having something like patchwork if I still have to
explain things to people by hand?  It doesn't save me any time, since
the whole point of patchwork is that I can communicate to the entire
world what state the patch is in and that tells what (if anything) can
happen next for that patch.

