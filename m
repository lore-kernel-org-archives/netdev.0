From: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch]startup race in hso driver
Date: Fri, 19 Dec 2008 10:20:54 +0100
Message-ID: <494B6776.4050309@option.com>
References: <200812181457.36340.oliver@neukum.org>	<494A5728.9070908@option.com> <20081218.195251.186334055.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org, ajb-5+cxppFmGx6/3pe1ocb+s/XRex20P6io@public.gmane.org, gregkh-l3A5Bk7waGM@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20081218.195251.186334055.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

No no no.
Please put it in Dave,
Our internal tree is a completely seperately maintained hso module
which is ifdeffed out of existance to compile back to 2.6.11.

It's typically made available at www.pharscape.org, the center
of the universe for 3G on linux.


David Miller wrote:
> From: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
> Date: Thu, 18 Dec 2008 14:59:04 +0100
> 
>> Thanks Oliver,
>> I'll add it to our internal tree.
> 
> Ok, I'll pull it out of net-next-2.6 then...


-- 
best regards,
D.J. Barrow

Linux Kernel Developer
Option NV, Gaston Geenslaan 14, 3001 Leuven, Belgium
 
T: +32 16 311 621
F: +32 16 207 164
Mobile Ireland: +353-86-1715438
Mobile Belgium  +32-496-226190
d.barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org
barrow_dj-/E1597aS9LQAvxtiuMwx3w@public.gmane.org
www.option.com
www.travelsmart.ie

Disclaimer:
http://www.option.com/company/disclaimer.shtml
 RPR Leuven 0429.375.448
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
