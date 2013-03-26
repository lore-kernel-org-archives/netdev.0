From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] libertas: drop maintainership
Date: Tue, 26 Mar 2013 09:22:19 -0500
Message-ID: <1364307739.1514.9.camel@dcbw.foobar.com>
References: <1363625321.1597.28.camel@dcbw.foobar.com>
	 <1363627392.2074.21.camel@joe-AO722>
	 <1363629095.6437.10.camel@dcbw.foobar.com>
	 <20130325185942.GC17454@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, Daniel Drake <dsd@laptop.org>,
	Bing Zhao <bzhao@marvell.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16092 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934400Ab3CZOV3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Mar 2013 10:21:29 -0400
In-Reply-To: <20130325185942.GC17454@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-03-25 at 14:59 -0400, John W. Linville wrote:
> On Mon, Mar 18, 2013 at 12:51:35PM -0500, Dan Williams wrote:
> > On Mon, 2013-03-18 at 10:23 -0700, Joe Perches wrote:
> > > On Mon, 2013-03-18 at 11:48 -0500, Dan Williams wrote:
> > > > Would be better maintained by somebody who actualy has time for it.
> > > []
> > > > diff --git a/MAINTAINERS b/MAINTAINERS
> > > []
> > > > -MARVELL LIBERTAS WIRELESS DRIVER
> > > > -M:	Dan Williams <dcbw@redhat.com>
> > > > -L:	libertas-dev@lists.infradead.org
> > > > -S:	Maintained
> > > > -F:	drivers/net/wireless/libertas/
> > > 
> > > I think it better to mark it as Orphan
> > > and maybe leave the list.
> > > 
> > > Maybe:
> > > 
> > > MARVELL LIBERTAS WIRELESS DRIVER
> > > L:	libertas-dev@lists.infradead.org
> > > S:	Orphan
> > > F:	drivers/net/wireless/libertas/
> > > 
> > > or
> > > 
> > > MARVELL LIBERTAS WIRELESS DRIVER
> > > S:	Orphan
> > > F:	drivers/net/wireless/libertas/
> > 
> > I can do that; I wasn't quite sure how to do this.  A quick check showed
> > patches that did what mine did, and oddly MAINTAINERS has no section for
> > dropping maintainership that I could quickly find.  If this is what
> > others prefer I'm happy to resubmit?
> 
> I probably would prefer an "Orphan" listing as well...

Ok, will do.

Dan
