From: Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] RDMA/addr: Use appropriate locking with for_each_netdev()
Date: Thu, 19 Nov 2009 22:48:24 -0800
Message-ID: <adak4xl669z.fsf@roland-alpha.cisco.com>
References: <4AF8EBA4.2070102@gmail.com>
	<D5E1FB213939498DBFFEB5A3B83C08AD@amr.corp.intel.com>
	<adaocn8x6j7.fsf@roland-alpha.cisco.com>
	<8C10E584257A46DB9A0AD193520CF4A7@amr.corp.intel.com>
	<4B0628E0.6000404@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Roland Dreier <rolandd-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>,
	Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-rdma <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4B0628E0.6000404-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> (Eric Dumazet's message of "Fri, 20
	Nov 2009 06:28:00 +0100")
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


 > Any news of this patch ?
 > 
 > We need it for 2.6.32 and also to prepare 2.6.33 with upcoming patches.

Sorry for not explicitly emailing about this patch.  I applied it as
part of Sean's series, but I just added it to my 2.6.33 queue.  At this
point in the release cycle it doesn't look severe enough for 2.6.32,
unless I miss something.

 - R.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
