From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: Re: another race in hso
Date: Mon, 12 Jan 2009 17:46:22 +0100
Message-ID: <200901121746.23686.oliver@neukum.org>
References: <200812221454.57794.oliver@neukum.org> <496B7159.3000500@option.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linux USB kernel mailing list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux netdev Mailing list <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <496B7159.3000500-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Monday 12 January 2009 17:35:37 schrieb Denis Joseph Barrow:
> Hi Oliver,
> Your patch fails in 3 places against 2.6.29-rc1,
> The first place being hso_serial_tiocmget.
> the spin_lock_irqsave is spin_lock_irq in my kernel sources.
> What kernel is this patch supposed to apply against?

Hi,

2.6.28

	Regards
		Oliver

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
