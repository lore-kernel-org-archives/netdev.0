From: Or Gerlitz <or.gerlitz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v1 for-next 0/3] IB: Use GFP_NOIO calls in IPoIB connected
 mode TX path
Date: Wed, 28 May 2014 17:12:59 +0300
Message-ID: <CAJZOPZ+ThgPaRVLe=y_0r0qrKofMOv4DSpfFymmaAD1cgCyQwQ@mail.gmail.com>
References: <1399810512-30774-1-git-send-email-ogerlitz@mellanox.com>
	<alpine.LNX.2.00.1405131338030.16459@pobox.suse.cz>
	<CAJZOPZJVxF6A-3s16feqoWCb5gOLTjyUmB3F+st1+1QWp+bJnQ@mail.gmail.com>
	<CAL1RGDUoEFF=fR-e-fc1v0yHp8sxaidBnO_2iiAFThgZNvCcfQ@mail.gmail.com>
	<alpine.LNX.2.00.1405261251520.12047@pobox.suse.cz>
	<CAJZOPZ+OPc9VWqwyE_erZfQbQ0VV-0yr7NiCyJOH5LUM_xyx2g@mail.gmail.com>
	<CAG4TOxMsq+okTzDrgTetDeXnAgQ+iGCZLbjAZx1iBD0xDmce6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Mel Gorman <mgorman-l3A5Bk7waGM@public.gmane.org>, Amir Vadai <amirv-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	linux-rdma <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Roland Dreier <roland.dreier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAG4TOxMsq+okTzDrgTetDeXnAgQ+iGCZLbjAZx1iBD0xDmce6g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, May 28, 2014 at 5:05 PM, Roland Dreier <roland.dreier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>
>
> > Roland, so M2 starts worrying, you have picked into your for-next
> > branch yesterday the other pending series, but not this one, so?
>
> Who is M2?

me too
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
