From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] MAINTAINERS: Add CAIF
Date: Thu, 09 Sep 2010 18:24:37 -0700
Message-ID: <1284081877.24986.251.camel@Joe-Laptop>
References: <1283880791.23280.153.camel@Joe-Laptop>
	 <81C3A93C17462B4BBD7E272753C1057916DE7CC568@EXDCVYMBSTM005.EQ1STM.local>
	 <1283927604.2479.1.camel@Joe-Laptop>
	 <20100909.143657.189709165.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: sjur.brandeland@stericsson.com, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1582 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752336Ab0IJBYk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Sep 2010 21:24:40 -0400
In-Reply-To: <20100909.143657.189709165.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-09-09 at 14:36 -0700, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Tue, 07 Sep 2010 23:33:24 -0700
> > Signed-off-by: Joe Perches <joe@perches.com>
> Saying something is "Supported" is a non-trivial commitment, so I'm
> not applying this until there is at least some kind of ACK from
> Sjur or one of the other CAIF hackers.

No worries, I corresponded with Sjur before posting that.

He should definitely ack it so you can commit it.

> > ---
> >  MAINTAINERS |   10 ++++++++++
> >  1 files changed, 10 insertions(+), 0 deletions(-)
> > 
> > diff --git a/MAINTAINERS b/MAINTAINERS
> > index c36f5d7..f2b3ece 100644
> > --- a/MAINTAINERS
> > +++ b/MAINTAINERS
> > @@ -1445,6 +1445,16 @@ S:	Maintained
> >  F:	Documentation/video4linux/cafe_ccic
> >  F:	drivers/media/video/cafe_ccic*
> >  
> > +CAIF NETWORK LAYER
> > +M:	Sjur Braendeland <sjur.brandeland@stericsson.com>
> > +L:	netdev@vger.kernel.org
> > +S:	Supported
> > +F:	Documentation/networking/caif/
> > +F:	drivers/net/caif/
> > +F:	include/linux/caif/
> > +F:	include/net/caif/
> > +F:	net/caif/
> > +
> >  CALGARY x86-64 IOMMU
> >  M:	Muli Ben-Yehuda <muli@il.ibm.com>
> >  M:	"Jon D. Mason" <jdmason@kudzu.us>


