From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed
 Topics
Date: Sun, 27 Mar 2005 20:34:58 -0800
Message-ID: <20050327203458.02bd73ee.davem@davemloft.net>
References: <4241D106.8050302@cs.wisc.edu>
	<20050324101622S.fujita.tomonori@lab.ntt.co.jp>
	<1111628393.1548.307.camel@beastie>
	<20050324113312W.fujita.tomonori@lab.ntt.co.jp>
	<1111633846.1548.318.camel@beastie>
	<20050324215922.GT14202@opteron.random>
	<424346FE.20704@cs.wisc.edu>
	<20050324233921.GZ14202@opteron.random>
	<20050325034341.GV32638@waste.org>
	<20050327035149.GD4053@g5.random>
	<20050327054831.GA15453@waste.org>
	<1111905181.4753.15.camel@mylaptop>
	<20050326224621.61f6d917.davem@davemloft.net>
	<Pine.LNX.4.61.0503272245350.30885@chimarrao.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dmitry_yus@yahoo.com, mpm@selenic.com, andrea@suse.de,
        michaelc@cs.wisc.edu, open-iscsi@googlegroups.com,
        James.Bottomley@HansenPartnership.com, ksummit-2005-discuss@thunk.org,
        netdev@oss.sgi.com
To: Rik van Riel <riel@redhat.com>
In-Reply-To: <Pine.LNX.4.61.0503272245350.30885@chimarrao.boston.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 27 Mar 2005 22:54:11 -0500 (EST)
Rik van Riel <riel@redhat.com> wrote:

> We shouldn't do that when we're really really low on
> memory.  I envision something like this:
 ...
>    (SO_MEMALLOC?)

Interesting top-down scheme.

We could also make a way to adjust the GFP_ATOMIC reserve
thresholds too.  That seems a bit more generic.
