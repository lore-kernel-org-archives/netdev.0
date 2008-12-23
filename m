From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: Re: [patch]startup race in hso driver
Date: Tue, 23 Dec 2008 13:33:48 +0100
Message-ID: <200812231333.50503.oliver@neukum.org>
References: <494A5728.9070908@option.com> <494B6776.4050309@option.com> <20081222.195420.82285555.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org, ajb-5+cxppFmGx6/3pe1ocb+s/XRex20P6io@public.gmane.org, gregkh-l3A5Bk7waGM@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20081222.195420.82285555.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Dienstag, 23. Dezember 2008 04:54:20 schrieb David Miller:
> From: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
> Date: Fri, 19 Dec 2008 10:20:54 +0100
> 
> > No no no.
> > Please put it in Dave,
> > Our internal tree is a completely seperately maintained hso module
> > which is ifdeffed out of existance to compile back to 2.6.11.
> > 
> > It's typically made available at www.pharscape.org, the center
> > of the universe for 3G on linux.
> 
> Ok, thanks for the clarification, I've put the patch back
> into net-next-2.6

Perhaps that issue should be documented in MAINTAINERS.

	Regards
		Oliver
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
