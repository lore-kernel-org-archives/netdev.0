From: Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH v1 for-next 0/3] IB: Use GFP_NOIO calls in IPoIB connected
 mode TX path
Date: Mon, 26 May 2014 12:52:41 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1405261251520.12047@pobox.suse.cz>
References: <1399810512-30774-1-git-send-email-ogerlitz@mellanox.com> <alpine.LNX.2.00.1405131338030.16459@pobox.suse.cz> <CAJZOPZJVxF6A-3s16feqoWCb5gOLTjyUmB3F+st1+1QWp+bJnQ@mail.gmail.com>
 <CAL1RGDUoEFF=fR-e-fc1v0yHp8sxaidBnO_2iiAFThgZNvCcfQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Or Gerlitz <or.gerlitz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Amir Vadai <amirv-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	linux-rdma <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Mel Gorman <mgorman-l3A5Bk7waGM@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAL1RGDUoEFF=fR-e-fc1v0yHp8sxaidBnO_2iiAFThgZNvCcfQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 19 May 2014, Roland Dreier wrote:

> > Roland, we're soon on -rc6 and there's no reason for this to miss
> > 3.16, could you please comment whether you want it to go through your
> > tree or net-next?
> 
> I will pick it up.

Thanks Roland.

Sorry for being a bit persistent, but another week has passed, -rc7 is out 
and I still don't see it in your tree. Could you please clarify what is 
the destiny of this patchset?

Thanks,

-- 
Jiri Kosina
SUSE Labs
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
