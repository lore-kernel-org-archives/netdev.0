From: Grant Grundler <grundler-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: usbnet: driver_info->stop required to stop USB interrupts?
Date: Tue, 11 Mar 2014 10:52:03 -0700
Message-ID: <CANEJEGtJqzVv6KGF15mt_PAqSKB+nJ_ysAuUhYvG+4GhxeLbeA@mail.gmail.com>
References: <CANEJEGsvqkT_H4i+UZpBaWMYmgXHmpD8SZ4tU1OHzLd8gyznow@mail.gmail.com>
	<CANEJEGv03ohVwoS0Pd1Z3az9k-C=dTzG4qE1SBL6Um97QC1Ehw@mail.gmail.com>
	<CAODwPW_t9COeg0LWfkiqXC_yTbSNhUHX-8T95KRZHfOTSiZK1Q@mail.gmail.com>
	<CANEJEGv77PnbLZsyOdTevXjij-_wLSq4uGCnSjnAwN9OK8m3Yg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Freddy Xin <freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Allan Chou <allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
To: Julius Werner <jwerner-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CANEJEGv77PnbLZsyOdTevXjij-_wLSq4uGCnSjnAwN9OK8m3Yg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 11, 2014 at 10:31 AM, Grant Grundler <grundler-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
> FWIW, I've reproduced this on "Samsung Chromebook" (Exynos 5250) with

FYA - I just noticed the system crashed on the 2048th iteration :)

...
RELOAD 2046  20140310202523  LINK 1000_full (3 sec)  IP 192.168.1.116 (1 Sec)
RELOAD 2047  20140310202533  LINK 1000_full (2 sec)  IP 192.168.1.116 (1 Sec)
RELOAD 2048   SSH timeout

thought folks would be amused by the coincidence.

grant
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
