From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] libertas: drop maintainership
Date: Mon, 25 Mar 2013 14:59:43 -0400
Message-ID: <20130325185942.GC17454@tuxdriver.com>
References: <1363625321.1597.28.camel@dcbw.foobar.com>
 <1363627392.2074.21.camel@joe-AO722>
 <1363629095.6437.10.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, Daniel Drake <dsd@laptop.org>,
	Bing Zhao <bzhao@marvell.com>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:40617 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757606Ab3CYTAo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 15:00:44 -0400
Content-Disposition: inline
In-Reply-To: <1363629095.6437.10.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 18, 2013 at 12:51:35PM -0500, Dan Williams wrote:
> On Mon, 2013-03-18 at 10:23 -0700, Joe Perches wrote:
> > On Mon, 2013-03-18 at 11:48 -0500, Dan Williams wrote:
> > > Would be better maintained by somebody who actualy has time for it.
> > []
> > > diff --git a/MAINTAINERS b/MAINTAINERS
> > []
> > > -MARVELL LIBERTAS WIRELESS DRIVER
> > > -M:	Dan Williams <dcbw@redhat.com>
> > > -L:	libertas-dev@lists.infradead.org
> > > -S:	Maintained
> > > -F:	drivers/net/wireless/libertas/
> > 
> > I think it better to mark it as Orphan
> > and maybe leave the list.
> > 
> > Maybe:
> > 
> > MARVELL LIBERTAS WIRELESS DRIVER
> > L:	libertas-dev@lists.infradead.org
> > S:	Orphan
> > F:	drivers/net/wireless/libertas/
> > 
> > or
> > 
> > MARVELL LIBERTAS WIRELESS DRIVER
> > S:	Orphan
> > F:	drivers/net/wireless/libertas/
> 
> I can do that; I wasn't quite sure how to do this.  A quick check showed
> patches that did what mine did, and oddly MAINTAINERS has no section for
> dropping maintainership that I could quickly find.  If this is what
> others prefer I'm happy to resubmit?

I probably would prefer an "Orphan" listing as well...

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
