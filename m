From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed Topics
Date: Mon, 4 Apr 2005 00:31:09 -0600
Message-ID: <20050404063109.GA30855@colo.lackof.org>
References: <20050324233921.GZ14202@opteron.random> <20050325034341.GV32638@waste.org> <20050327035149.GD4053@g5.random> <20050327054831.GA15453@waste.org> <1111905181.4753.15.camel@mylaptop> <20050326224621.61f6d917.davem@davemloft.net> <52vf7bwo4w.fsf@topspin.com> <1112042936.5088.22.camel@beastie> <20050328223203.GC28983@kvack.org> <1112465317.24936.10.camel@mylaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "open-iscsi@googlegroups.com" <open-iscsi@googlegroups.com>,
        "David S. Miller" <davem@davemloft.net>, mpm@selenic.com,
        andrea@suse.de, michaelc@cs.wisc.edu,
        James.Bottomley@HansenPartnership.com, ksummit-2005-discuss@thunk.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Dmitry Yusupov <dmitry_yus@yahoo.com>
Content-Disposition: inline
In-Reply-To: <1112465317.24936.10.camel@mylaptop>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Apr 02, 2005 at 10:08:37AM -0800, Dmitry Yusupov wrote:
> So, who cares if one of those cores will do receive side copying?

It burns backplane bandwidth that could be used for other things.
The problem isn't the CPU cycles. It's the number
of times the data has to cross the memory bus.

grant
