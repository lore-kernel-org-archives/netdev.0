From: Maxim <maximlevitsky@gmail.com>
Subject: Re: [PATCH] MAINTAINERS: no DMFE maintainer
Date: Mon, 12 Feb 2007 00:22:15 +0200
Message-ID: <200702120022.15999.maximlevitsky@gmail.com>
References: <20070209143106.9dc30c9b.randy.dunlap@oracle.com> <45CCF978.40006@garzik.org> <20070209145404.d317a496.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jeff@garzik.org>, netdev <netdev@vger.kernel.org>,
	tori@unhappy.mine.nu, Levitsky Maxim <maximlevitsky@yahoo.com>
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:14997 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932586AbXBKWWV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Feb 2007 17:22:21 -0500
Received: by nf-out-0910.google.com with SMTP id o25so2020830nfa
        for <netdev@vger.kernel.org>; Sun, 11 Feb 2007 14:22:19 -0800 (PST)
In-Reply-To: <20070209145404.d317a496.randy.dunlap@oracle.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 10 February 2007 00:54:04 Randy Dunlap wrote:
> On Fri, 09 Feb 2007 17:45:12 -0500 Jeff Garzik wrote:
> > Randy Dunlap wrote:
> > > From: Randy Dunlap <randy.dunlap@oracle.com>
> > >
> > > Tobias wrote that he no longer maintains this driver and requeste=
d
> > > to be removed from MAINTAINERS.
> > >
> > > Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> > > ---
> > >  MAINTAINERS |    4 +---
> > >  1 file changed, 1 insertion(+), 3 deletions(-)
> >
> > Levitsky Maxim <maximlevitsky@yahoo.com> just posted a bunch of pat=
ches
> > to the dmfe driver, maybe you could ping him?
>
> Hi Maxim,
> What do you think about this patch to the MAINTAINERS file
> based on your recent DMFE patch history?
>
> ---
>
> From: Randy Dunlap <randy.dunlap@oracle.com>
>
> Tobias wrote that he no longer maintains this driver and requested
> to be removed from MAINTAINERS.  However, Levitsky Maxim has been
> active on DMFE recently.
>
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> ---
>  MAINTAINERS |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> --- linux-2.6.20-git5.orig/MAINTAINERS
> +++ linux-2.6.20-git5/MAINTAINERS
> @@ -1112,8 +1112,8 @@ T:	git kernel.org:/pub/scm/linux/kernel/
>  S:	Supported
>
>  DAVICOM FAST ETHERNET (DMFE) NETWORK DRIVER
> -P:	Tobias Ringstrom
> -M:	tori@unhappy.mine.nu
> +P:	Levitsky Maxim
> +M:	maximlevitsky@yahoo.com
>  L:	netdev@vger.kernel.org
>  S:	Maintained
>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Hello, I forgot to tell that I will not use maximlevitsky@yahoo.com as =
my mailbox any more:

---

=46rom: Randy Dunlap <randy.dunlap@oracle.com>

Tobias wrote that he no longer maintains this driver and requested
to be removed from MAINTAINERS. =A0However, Levitsky Maxim has been
active on DMFE recently.

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
=A0MAINTAINERS | =A0 =A04 ++--
=A01 file changed, 2 insertions(+), 2 deletions(-)

--- linux-2.6.20-git5.orig/MAINTAINERS
+++ linux-2.6.20-git5/MAINTAINERS
@@ -1112,8 +1112,8 @@ T:=A0=A0=A0=A0=A0=A0=A0=A0git kernel.org:/pub/scm=
/linux/kernel/
=A0S:=A0=A0=A0=A0=A0Supported
=A0
=A0DAVICOM FAST ETHERNET (DMFE) NETWORK DRIVER
-P:=A0=A0=A0=A0=A0Tobias Ringstrom
-M:=A0=A0=A0=A0=A0tori@unhappy.mine.nu
+P:=A0=A0=A0=A0=A0Levitsky Maxim
+M:=A0=A0=A0=A0=A0maximlevitsky@gmail.com
=A0L:=A0=A0=A0=A0=A0netdev@vger.kernel.org
=A0S:=A0=A0=A0=A0=A0Maintained
=A0
