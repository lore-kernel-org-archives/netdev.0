From: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: RE: [PATCH net-next V2 00/21] net/mlx4: SRIOV support
Date: Mon, 2 Jan 2012 07:55:38 +0000
Message-ID: <953B660C027164448AE903364AC447D24CDA8704@MTLDAG01.mtl.com>
References: <4EE75CD1.7070900@mellanox.co.il>
	<20111213.141413.1872427395829102426.davem@davemloft.net>
	<953B660C027164448AE903364AC447D2485F0A86@MTLDAG02.mtl.com>
	<CAE9FiQU1EwcGBhn2bFksB30nb8p3FEo=vvOJYXq3hAA1ArhqWg@mail.gmail.com>
	<CAJZOPZJ+BxAa_OcB0f5nPAjnW7eZfsDdXz_o-VSCW7dsp5p2wg@mail.gmail.com>
	<CAE9FiQW2ZB3VUrg9z-=UVp=s3w1LQhY81hRUjfMXwW3d1dNaig@mail.gmail.com>
	<CAL1RGDWa+8gv8WZrCtQBpzAQUkD982ONODE7qRjUs_Gn2m4DKA@mail.gmail.com>
 <CAE9FiQX1q+qFHrGJdX5aZ9ix0bZ-vH3xEWPqFcRab87a9y2vrQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Or Gerlitz <or.gerlitz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org" <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
To: Yinghai Lu <yinghai-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAE9FiQX1q+qFHrGJdX5aZ9ix0bZ-vH3xEWPqFcRab87a9y2vrQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> >
> >> hotplug removal is broken...
> >
> > Is this a new regression with these patches?
> >
> 
> yes.
> 
> after reverting those patches, removal work well without problem.
> 
> Thanks
> 
> Yinghai

Thanks,
We just found the same failure internally.
Will send a fix shortly.

Yevgeny
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
