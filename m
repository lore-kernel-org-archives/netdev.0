From: "Perez-Gonzalez, Inaky" <inaky.perez-gonzalez-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: RE: [RFC 1/2] i2400m: remove SDIO device support
Date: Wed, 11 Jul 2012 16:50:27 +0000
Message-ID: <3A78FAA0EC814D4B8ECC99B3AB32B33208141AC2@fmsmsx110.amr.corp.intel.com>
References: <1341952049-32193-1-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Ortiz, Samuel" <samuel.ortiz-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	linux-wimax <linux-wimax-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"wimax-BPSAo7wm5JOHVYUYWc+uSQ@public.gmane.org" <wimax-BPSAo7wm5JOHVYUYWc+uSQ@public.gmane.org>
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1341952049-32193-1-git-send-email-linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Content-Language: en-US
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> From: John W. Linville [mailto:linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org]
> 
> From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> 
> SDIO support in this driver was intended to support the iwmc3200
> device.  This hardware never became available to normal humans.
> Leaving this driver imposes unwelcome maintenance costs for no clear
> benefit.
> 
> Cc: Inaky Perez-Gonzalez <inaky.perez-gonzalez-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> ---
> If there are no objections, I'll push this series through the
> wireless-next tree along with the iwmc3200wifi removal.

Acked-by: Inaky Perez-Gonzalez <inaky.perez-gonzalez-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
