From: Jamie Iles <jamie@jamieiles.com>
Subject: Re: [PATCHv3 0/9] macb: add support for Cadence GEM
Date: Tue, 23 Aug 2011 10:34:53 +0100
Message-ID: <20110823093453.GJ2796@pulham.picochip.com>
References: <1312881411-2376-1-git-send-email-jamie@jamieiles.com>
 <20110809145940.GP22213@game.jcrosoft.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamie Iles <jamie@jamieiles.com>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:53989 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754579Ab1HWJfD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2011 05:35:03 -0400
Received: by wyg24 with SMTP id 24so4053379wyg.19
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2011 02:35:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20110809145940.GP22213@game.jcrosoft.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jean-Christoph,

On Tue, Aug 09, 2011 at 04:59:40PM +0200, Jean-Christophe PLAGNIOL-VILLARD wrote:
> On 10:16 Tue 09 Aug     , Jamie Iles wrote:
> > This is largely a repost of the series I posted back in March.  The only changes
> > since then are rebasing onto 3.1-rc1 and changing the gem conditionals from a
> > boolean in the macb structure to an inline helper as requested by
> > Jean-Christophe.
> > 
> > This has been run-tested on picoxcell and compile tested for all AT91 platforms
> > but I couldn't get a working cross compiler for avr32.
> > 
> > All patches are available in a git branch at
> > 
> > 	git://github.com/jamieiles/linux-2.6-ji.git macb-gem
> > 
> looks good except few comments
> 
> I'll test it later this week

Have you had chance to test this series?  I'd like to get it into Arnd's 
tree and into next for a bit so we can get it into the next release if 
possible.

Thanks,

Jamie
