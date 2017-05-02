From: Ursula Braun <ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: net/smc and the RDMA core
Date: Tue, 2 May 2017 14:25:59 +0200
Message-ID: <d9214af6-1c6f-9f95-fc00-3e4a316b4f81@linux.vnet.ibm.com>
References: <20170501163311.GA22209@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170501163311.GA22209-jcswGhMUV9g@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


On 05/01/2017 06:33 PM, Christoph Hellwig wrote:
> Hi Ursual, hi netdev reviewers,
> 
> how did the smc protocol manage to get merged without any review 
> on linux-rdma at all?  As the results it seems it's very substandard
> in terms of RDMA API usage, e.g. it neither uses the proper CQ API
> nor the RDMA R/W API, and other will probably find additional issues
> as well.
>
Hi Christoph,

We have been posting SMC-R patches on netdev since 2015, there was never 
any secrecy about it. Still sorry for omitting linux-rdma, will include 
with future postings from now on. 
Of course, we are open to any further code reviews, so if you can point 
out specific issues, we will be happy to work with you to get them 
addressed!
 
Regards, Ursula

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
