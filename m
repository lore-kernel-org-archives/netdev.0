From: Roland Dreier <roland@topspin.com>
Subject: Linux support for RDMA (was: [Ksummit-2005-discuss] Summary of 2005
 Kernel Summit Proposed Topics)
Date: Mon, 28 Mar 2005 19:19:35 -0800
Message-ID: <52psxjt9yw.fsf_-_@topspin.com>
References: <20050324215922.GT14202@opteron.random>
	<424346FE.20704@cs.wisc.edu> <20050324233921.GZ14202@opteron.random>
	<20050325034341.GV32638@waste.org> <20050327035149.GD4053@g5.random>
	<20050327054831.GA15453@waste.org> <1111905181.4753.15.camel@mylaptop>
	<20050326224621.61f6d917.davem@davemloft.net>
	<52vf7bwo4w.fsf@topspin.com> <1112042936.5088.22.camel@beastie>
	<20050328223203.GC28983@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Yusupov <dmitry_yus@yahoo.com>, open-iscsi@googlegroups.com,
        "David S. Miller" <davem@davemloft.net>, mpm@selenic.com,
        andrea@suse.de, michaelc@cs.wisc.edu,
        James.Bottomley@HansenPartnership.com, ksummit-2005-discuss@thunk.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Benjamin LaHaise <bcrl@kvack.org>
In-Reply-To: <20050328223203.GC28983@kvack.org> (Benjamin LaHaise's message
 of "Mon, 28 Mar 2005 17:32:03 -0500")
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

    Benjamin> Agreed.  After working on a full TOE implementation, I
    Benjamin> think that the niche market most TOE vendors are
    Benjamin> pursuing is not one that the Linux community will ever
    Benjamin> develop for.  Hardware vendors that gradually add
    Benjamin> offloading features from the NIC realm to speed up the
    Benjamin> existing network stack are a much better fit with Linux.

I have to admit I don't know much about the TOE / RDMA/TCP / RNIC (or
whatever you want to call it) world.  However I know that the large
majority of InfiniBand use right now is running on Linux, and I hope
the Linux community is willing to work with the IB community.

InfiniBand adoption is strong right now, with lots of large clusters
being built.  It seems reasonable that RDMA/TCP should be able to
compete in the same market.  Whether InfiniBand or RDMA/TCP or both
will survive or prosper is a good question, and I think it's too early
to tell yet.

 - R.
