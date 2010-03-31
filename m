From: Rory Filer <rfiler-usJ8hg9QsBLWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>
Subject: RE: re-submit2 [ANNOUNCEMENT] NET: usb: sierra_net.c driver
Date: Tue, 30 Mar 2010 23:21:25 -0700
Message-ID: <8F90F944E50427428C60E12A34A309D22FC800D825@carmd-exchmb01.sierrawireless.local>
References: <1269893596.9242.7.camel@Linuxdev3>
	<20100330.230932.244208287.davem@davemloft.net>
 <20100330.231051.113008279.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org" <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100330.231051.113008279.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Content-Language: en-US
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

 -----Original Message-----
> >
> > Applied, thanks.
> 
> Nevermind, reverted, it doesn't even build.
> 
> drivers/net/usb/sierra_net.c: In function 'check_ethip_packet':
> drivers/net/usb/sierra_net.c:221:3: error: implicit declaration of
> function 'deverr'
> 
> Really, this should never ever happen, and there is simply
> no excuse at all for this.

Well actually there is an excuse, but I'm sure you don't want to
know what it is. 
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
