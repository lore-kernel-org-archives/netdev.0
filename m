From: Dmitry Kozlov <xeb@mail.ru>
Subject: =?koi8-r?Q?Re=3A_[PATCH_3/3]_PPTP=3A_PPP_over_IPv4_(Point-to-Point_Tunneling_Protocol)?=
Date: Thu, 05 Aug 2010 09:55:17 +0400
Message-ID: <E1OgtQD-0007c9-00.xeb-mail-ru@f254.mail.ru>
References: <20100804212251.59c08e58.billfink@mindspring.com>
Reply-To: Dmitry Kozlov <xeb@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from f254.mail.ru ([217.69.128.179]:43178 "EHLO f254.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756669Ab0HEFzV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Aug 2010 01:55:21 -0400
In-Reply-To: <20100804212251.59c08e58.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 4 Aug 2010 21:22:51 -0400 Bill Fink <billfink@mindspring.com> wrote:
> On Wed, 04 Aug 2010, xeb@mail.ru wrote:
> 
> > This is patch 3/3 which contains MAINTAINERS file modification.
> > 
> > ---
> >  MAINTAINERS |   14 ++++++++++++++
> >  1 files changed, 14 insertions(+), 0 deletions(-)
> > 
> > diff --git a/MAINTAINERS b/MAINTAINERS
> > index 02f75fc..313d829 100644
> > --- a/MAINTAINERS
> > +++ b/MAINTAINERS
> > @@ -6450,6 +6450,20 @@ M:	"Maciej W. Rozycki" <macro@linux-mips.org>
> >  S:	Maintained
> >  F:	drivers/serial/zs.*
> >  
> > +GRE DEMULTIPLEXER DRIVER
> > +M:	Dmitry Kozlov <xeb@mail.ru>
> > +L:	linux-net@vger.kernel.org
> 
> Shouldn't this also be:
> 
> +L:	netdev@vger.kernel.org
> 
> just like the PPTP DRIVER entry below?
> 
> 			-Bill

Seems like it should ... will be fixed.
