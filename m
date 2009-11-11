From: "Sean Hefty" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: RE: [PATCH] RDMA/addr: Use appropriate locking with for_each_netdev()
Date: Wed, 11 Nov 2009 12:55:42 -0800
Message-ID: <8C10E584257A46DB9A0AD193520CF4A7@amr.corp.intel.com>
References: <4AF8EBA4.2070102@gmail.com>	<D5E1FB213939498DBFFEB5A3B83C08AD@amr.corp.intel.com> <adaocn8x6j7.fsf@roland-alpha.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'Eric Dumazet'" <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Linux Netdev List" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Roland Dreier" <rolandd-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>,
	"Hal Rosenstock" <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linux-rdma" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "'Roland Dreier'" <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <adaocn8x6j7.fsf-BjVyx320WGW9gfZ95n9DRSW4+XlvGpQz@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

>Would it be possible for you to take Eric's patch as the first in your
>set (keeping his From: of course) and base your fixes on top of that?

Will do.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
