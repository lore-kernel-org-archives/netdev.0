From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] Update MAINTAINERS for USB network devices
Date: Wed, 27 Jun 2007 04:23:28 -0400
Message-ID: <46821E80.8080105@garzik.org>
References: <87myyl6df1.fsf@nanv.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	David Brownell <dbrownell@users.sourceforge.net>,
	Petko Manolov <petkan@nucleusys.com>
To: Peter Korsgaard <jacmet@sunsite.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38575 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751847AbXF0IXg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2007 04:23:36 -0400
In-Reply-To: <87myyl6df1.fsf@nanv.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Peter Korsgaard wrote:
> Questions regarding the USB network drivers should now go to netdev.
> 
> Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
> ---
>  MAINTAINERS |   13 +++++--------
>  1 file changed, 5 insertions(+), 8 deletions(-)
> 
> Index: linux-2.6.22-rc6/MAINTAINERS
> ===================================================================
> --- linux-2.6.22-rc6.orig/MAINTAINERS
> +++ linux-2.6.22-rc6/MAINTAINERS
> @@ -3610,15 +3610,14 @@
>  USB CDC ETHERNET DRIVER
>  P:	Greg Kroah-Hartman
>  M:	greg@kroah.com
> -L:	linux-usb-users@lists.sourceforge.net
> -L:	linux-usb-devel@lists.sourceforge.net
> +L:	netdev@vger.kernel.org
>  S:	Maintained
>  W:	http://www.kroah.com/linux-usb/
>  
>  USB DAVICOM DM9601 DRIVER
>  P:	Peter Korsgaard
>  M:	jacmet@sunsite.dk
> -L:	linux-usb-devel@lists.sourceforge.net
> +L:	netdev@vger.kernel.org
>  W:	http://www.linux-usb.org/usbnet
>  S:	Maintained
>  
> @@ -3702,8 +3701,7 @@
>  USB PEGASUS DRIVER
>  P:	Petko Manolov
>  M:	petkan@users.sourceforge.net
> -L:	linux-usb-users@lists.sourceforge.net
> -L:	linux-usb-devel@lists.sourceforge.net
> +L:	netdev@vger.kernel.org
>  W:	http://pegasus2.sourceforge.net/
>  S:	Maintained
>  
> @@ -3717,8 +3715,7 @@
>  USB RTL8150 DRIVER
>  P:	Petko Manolov
>  M:	petkan@users.sourceforge.net
> -L:	linux-usb-users@lists.sourceforge.net
> -L:	linux-usb-devel@lists.sourceforge.net
> +L:	netdev@vger.kernel.org
>  W:	http://pegasus2.sourceforge.net/
>  S:	Maintained
>  
> @@ -3829,7 +3826,7 @@
>  USB "USBNET" DRIVER FRAMEWORK
>  P:	David Brownell
>  M:	dbrownell@users.sourceforge.net
> -L:	linux-usb-devel@lists.sourceforge.net
> +L:	netdev@vger.kernel.org
>  W:	http://www.linux-usb.org/usbnet
>  S:	Maintained

Quite true, but for courtesy's sake you should keep the relevant 
maintainers in the loop, and get their ACKs, when you start changing 
their MAINTAINERS entries.

	Jeff



