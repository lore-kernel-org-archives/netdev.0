From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: Linux support for RDMA
Date: Wed, 30 Mar 2005 17:08:12 -0800
Message-ID: <424B4D7C.1000302@zytor.com>
References: <20050324233921.GZ14202@opteron.random> <20050325034341.GV32638@waste.org> <20050327035149.GD4053@g5.random> <20050327054831.GA15453@waste.org> <1111905181.4753.15.camel@mylaptop> <20050326224621.61f6d917.davem@davemloft.net> <52vf7bwo4w.fsf@topspin.com> <1112042936.5088.22.camel@beastie> <20050328223203.GC28983@kvack.org> <52psxjt9yw.fsf_-_@topspin.com> <20050330160006.GE2927@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <roland@topspin.com>, Dmitry Yusupov <dmitry_yus@yahoo.com>,
        open-iscsi@googlegroups.com, "David S. Miller" <davem@davemloft.net>,
        mpm@selenic.com, andrea@suse.de, michaelc@cs.wisc.edu,
        James.Bottomley@HansenPartnership.com, ksummit-2005-discuss@thunk.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Benjamin LaHaise <bcrl@kvack.org>
In-Reply-To: <20050330160006.GE2927@kvack.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Benjamin LaHaise wrote:
>  
> I'm curious how the 10Gig ethernet market will pan out.  Time and again 
> the market has shown that ethernet always has the cost advantage in the 
> end.  If something like Intel's I/O Acceleration Technology makes it 
> that much easier for commodity ethernet to achieve similar performance 
> characteristics over ethernet to that of IB and fibre channel, the cost 
> advantage alone might switch some new customers over.  But the hardware 
> isn't near what IB offers today, making IB an important niche filler.
> 

 From what I've seen coming down the pipe, I think 10GE is going to 
eventually win over IB, just like previous generations did over Token 
Ring, FDDI and other niche filler technologies.  It doesn't, as you say, 
mean that e.g. IB doesn't matter *now*; furthermore, it also matters for 
the purpose of fixing the kind of issues that are going to have to be 
fixed anyway.

	-hpa
