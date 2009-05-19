From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] bc47xx : export ssb_watchdog_timer_set
Date: Tue, 19 May 2009 13:35:03 -0400
Message-ID: <20090519173503.GD2691@tuxdriver.com>
References: <4A11DCBF.9000700@free.fr> <200905191524.20421.mb@bu3sch.de> <20090519170957.GA23711@linux-mips.org> <200905191929.21082.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ralf Baechle <ralf@linux-mips.org>,
	matthieu castet <castet.matthieu@free.fr>,
	linux-mips@linux-mips.org, netdev@vger.kernel.org
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57318 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751265AbZESRpL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 13:45:11 -0400
Content-Disposition: inline
In-Reply-To: <200905191929.21082.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 19, 2009 at 07:29:20PM +0200, Michael Buesch wrote:
> On Tuesday 19 May 2009 19:09:57 Ralf Baechle wrote:
> > Maybe because I felt drivers/ssb/ was outside my jurisdiction - and unlike
> > what alot of people may seem to think I'm not a full time MIPS kernel
> > hacker.
> 
> Ok nice.
> 
> > I can deal with SSB patch if you so desire - but I have no experience with
> > SSB, so I'd have somebody to rubberstamp non-trivial SSB patches before I
> > queue them up.
> 
>  **Fwoo..
> [stamp here]
>       ..mppp**
> 
> 
> Done. :)
> 
> > I can keep them either in the usual MIPS trees on 
> > linux-mips.org or I could create a separate linux-ssb tree, depending on
> > what seems to be sensible.  Also, reading the entry in the maintainers
> > file I wonder if netdev is really the list of a choice?
> 
> Yes it is, because the bus is only used on networking devices.
> (Ethernet cards, wireless cards, and network routers)
> I don't think you need to create a separate tree. ssb is pretty mature. There
> won't be that many patches.

OK, now I'm confused again -- should I take SSB patches, or is Ralf
going to do it? :-)

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
