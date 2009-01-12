From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] hso driver fix for big endian machines.
Date: Mon, 12 Jan 2009 16:04:40 +0100
Message-ID: <200901121604.41727.oliver@neukum.org>
References: <496B5ABE.2060406@option.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Linux netdev Mailing list <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux USB kernel mailing list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Paul Hardwick <P.Hardwick-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
To: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <496B5ABE.2060406-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Monday 12 January 2009 15:59:10 schrieb Denis Joseph Barrow:
> This patch is against 2.6.29-rc1 I hope it'll apply to other trees if neccessary.
> Filip Aben says this fix is neccessary for big endian machines.

He's correct. They are needed.

	Regards
		Oliver

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
