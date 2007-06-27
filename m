From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH] Update MAINTAINERS for USB network devices
Date: Wed, 27 Jun 2007 01:54:15 -0700
Message-ID: <200706270154.16022.david-b@pacbell.net>
References: <87myyl6df1.fsf@nanv.dk> <46821E80.8080105@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Peter Korsgaard <jacmet@sunsite.dk>, netdev@vger.kernel.org,
	Petko Manolov <petkan@nucleusys.com>, Greg KH <greg@kroah.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp118.sbc.mail.sp1.yahoo.com ([69.147.64.91]:37246 "HELO
	smtp118.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752521AbXF0JBB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2007 05:01:01 -0400
In-Reply-To: <46821E80.8080105@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 27 June 2007, Jeff Garzik wrote:
> Peter Korsgaard wrote:
> > Questions regarding the USB network drivers should now go to netdev.
> > 
> > Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
> > ---
> >  MAINTAINERS |   13 +++++--------
> >  1 file changed, 5 insertions(+), 8 deletions(-)
> > 
> > Index: linux-2.6.22-rc6/MAINTAINERS
> > ===================================================================
> > --- linux-2.6.22-rc6.orig/MAINTAINERS
> > +++ linux-2.6.22-rc6/MAINTAINERS
> > @@ -3610,15 +3610,14 @@
> >  USB CDC ETHERNET DRIVER
> >  P:	Greg Kroah-Hartman

I think that may refer to the old cdc ethernet driver
though ... Greg?  The new one, in the usbnet framework,
is a very different beast...


> >  M:	greg@kroah.com
> > -L:	linux-usb-users@lists.sourceforge.net
> > -L:	linux-usb-devel@lists.sourceforge.net
> > +L:	netdev@vger.kernel.org
> >  S:	Maintained
> >  W:	http://www.kroah.com/linux-usb/
> >  
> >  USB DAVICOM DM9601 DRIVER
> >  P:	Peter Korsgaard
> >  M:	jacmet@sunsite.dk
> > -L:	linux-usb-devel@lists.sourceforge.net
> > +L:	netdev@vger.kernel.org
> >  W:	http://www.linux-usb.org/usbnet
> >  S:	Maintained
> >  
> > @@ -3702,8 +3701,7 @@
> >  USB PEGASUS DRIVER
> >  P:	Petko Manolov
> >  M:	petkan@users.sourceforge.net
> > -L:	linux-usb-users@lists.sourceforge.net
> > -L:	linux-usb-devel@lists.sourceforge.net
> > +L:	netdev@vger.kernel.org
> >  W:	http://pegasus2.sourceforge.net/
> >  S:	Maintained
> >  
> > @@ -3717,8 +3715,7 @@
> >  USB RTL8150 DRIVER
> >  P:	Petko Manolov
> >  M:	petkan@users.sourceforge.net
> > -L:	linux-usb-users@lists.sourceforge.net
> > -L:	linux-usb-devel@lists.sourceforge.net
> > +L:	netdev@vger.kernel.org
> >  W:	http://pegasus2.sourceforge.net/
> >  S:	Maintained
> >  
> > @@ -3829,7 +3826,7 @@
> >  USB "USBNET" DRIVER FRAMEWORK
> >  P:	David Brownell
> >  M:	dbrownell@users.sourceforge.net
> > -L:	linux-usb-devel@lists.sourceforge.net
> > +L:	netdev@vger.kernel.org
> >  W:	http://www.linux-usb.org/usbnet
> >  S:	Maintained
> 
> Quite true, but for courtesy's sake you should keep the relevant 
> maintainers in the loop, and get their ACKs, when you start changing 
> their MAINTAINERS entries.

Acked-by-Me.


> 
> 	Jeff
> 
> 
> 


