From: jaganav@us.ibm.com
Subject: Re: Linux support for RDMA
Date: Thu, 31 Mar 2005 20:49:08 -0500
Message-ID: <1112320148.424ca894f3c8b@imap.linux.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: Roland Dreier <roland@topspin.com>, Dmitry Yusupov <dmitry_yus@yahoo.com>,
        open-iscsi@googlegroups.com, "David S. Miller" <davem@davemloft.net>,
        mpm@selenic.com, andrea@suse.de, michaelc@cs.wisc.edu,
        James.Bottomley@HansenPartnership.com, ksummit-2005-discuss@thunk.org,
        netdev@oss.sgi.com, Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "H. Peter Anvin" <hpa@zytor.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Quoting "H. Peter Anvin" <hpa@zytor.com>:
> Benjamin LaHaise wrote:
> >  
> > I'm curious how the 10Gig ethernet market will pan out.  Time and again 
> > the market has shown that ethernet always has the cost advantage in the 
> > end.  If something like Intel's I/O Acceleration Technology makes it 
> > that much easier for commodity ethernet to achieve similar performance 
> > characteristics over ethernet to that of IB and fibre channel, the cost 
> > advantage alone might switch some new customers over.  But the hardware 
> > isn't near what IB offers today, making IB an important niche filler.
> > 
> 
>  From what I've seen coming down the pipe, I think 10GE is going to 
> eventually win over IB, just like previous generations did over Token 
> Ring, FDDI and other niche filler technologies.  It doesn't, as you say, 
> mean that e.g. IB doesn't matter *now*; furthermore, it also matters for 
> the purpose of fixing the kind of issues that are going to have to be 
> fixed anyway.
> 
> 	-hpa
> 
> 
> 

No doubt, Ethernet will eventually win .. btw, Hasn't history proven this over
ATM? More specifically when the industry predicted that ATM will replace
ethernet :)

However, I'll have to agree with Ben that IB technolgy will fill an important
niche segment, more specifically so in the low end of High Performance Computing
(HPC) segment which is in a transition mode currently moving away from
proprietary interconnects to industry standards based IB technology. Eventhough,
ethernet may eventually may catch up with IB in terms of the bandwidth but IB
fabrics can offer better latencies.

Thanks
Venkat
