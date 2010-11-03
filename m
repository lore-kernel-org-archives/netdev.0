From: "Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
Subject: Re: [PATCH] bluetooth: cmtp: fix information leak to userland
Date: Wed, 3 Nov 2010 14:36:30 -0400
Message-ID: <20101103183630.GC17943@vigoh>
References: <1288448787-5848-1-git-send-email-segooon@gmail.com>
 <1288712158.3322.179.camel@aeonflux>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vasiliy Kulikov <segooon-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1288712158.3322.179.camel@aeonflux>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

* Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org> [2010-11-02 16:35:58 +0100]:

> Hi Vasiliy,
> 
> > Structure cmtp_conninfo is copied to userland with some padding fields
> > unitialized.  It leads to leaking of contents of kernel stack memory.
> > 
> > Signed-off-by: Vasiliy Kulikov <segooon-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> 
> Acked-by: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>

Applied, thanks.  

-- 
Gustavo F. Padovan
ProFUSION embedded systems - http://profusion.mobi
