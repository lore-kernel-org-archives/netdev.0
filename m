From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: Linux support for RDMA
Date: Thu, 31 Mar 2005 17:57:22 -0800
Message-ID: <424CAA82.1010707@zytor.com>
References: <1112320148.424ca894f3c8b@imap.linux.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <roland@topspin.com>, Dmitry Yusupov <dmitry_yus@yahoo.com>,
        open-iscsi@googlegroups.com, "David S. Miller" <davem@davemloft.net>,
        mpm@selenic.com, andrea@suse.de, michaelc@cs.wisc.edu,
        James.Bottomley@HansenPartnership.com, ksummit-2005-discuss@thunk.org,
        netdev@oss.sgi.com, Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: jaganav@us.ibm.com
In-Reply-To: <1112320148.424ca894f3c8b@imap.linux.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jaganav@us.ibm.com wrote:
> 
> No doubt, Ethernet will eventually win .. btw, Hasn't history proven this over
> ATM? More specifically when the industry predicted that ATM will replace
> ethernet :)
> 
> However, I'll have to agree with Ben that IB technolgy will fill an important
> niche segment, more specifically so in the low end of High Performance Computing
> (HPC) segment which is in a transition mode currently moving away from
> proprietary interconnects to industry standards based IB technology. Eventhough,
> ethernet may eventually may catch up with IB in terms of the bandwidth but IB
> fabrics can offer better latencies.
> 

We've seen this over and over... Token Ring, FDDI, ATM, IB, ... all of 
them "better" than the Ethernet of the day, but eventually 
commoditization wins out.  With 10GE, Ethernet has finally stopped 
pretending to be CSMA/CD even; "Ethernet" is now really nothing more 
than a collective name for a set of somewhat compatible commodity 
networking technologies.

	-hpa
