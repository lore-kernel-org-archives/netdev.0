From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: IPv6 path discovery oddities - flushing the routing cache
 resolves
Date: Sat, 19 Oct 2013 12:12:46 +0200
Message-ID: <20131019101246.GA27576@sesse.net>
References: <525E6B03.1040409@blub.net>
 <20131016154841.GC18135@order.stressinduktion.org>
 <525FC1C4.3070605@blub.net>
 <20131018030440.GI18135@order.stressinduktion.org>
 <5260D8DE.30303@blub.net>
 <20131019084225.GA31333@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Valentijn Sessink <valentyn@blub.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([193.35.52.29]:50780 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750843Ab3JSKMu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Oct 2013 06:12:50 -0400
Content-Disposition: inline
In-Reply-To: <20131019084225.GA31333@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 19, 2013 at 10:42:25AM +0200, Hannes Frederic Sowa wrote:
> I got access to a nice test box yesterday where I could brute force the
> problem in parallel (it was a PITA). This is what I found:

Thanks so much for looking into this! It's great that to hear that it's not
just me being weird =) I'll try rebooting the machine in question into a
kernel with these patches later today; given how intermittent it is, it can
of course only show if the patches are not fully working (or, over time,
make it likely that they are).

/* Steinar */
-- 
Homepage: http://www.sesse.net/
