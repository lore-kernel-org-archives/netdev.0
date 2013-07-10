From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2] socket.7: add description for SO_BUSY_POLL
Date: Wed, 10 Jul 2013 11:52:15 -0700 (PDT)
Message-ID: <20130710.115215.1793423861402826221.davem@davemloft.net>
References: <20130710141835.15799.61657.stgit@ladj378.jer.intel.com>
	<51DDA1DC.2020306@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eliezer.tamir-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, eliezer-rsSRdLmRgNEQhDRD3CWCHA@public.gmane.org
To: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <51DDA1DC.2020306-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Wed, 10 Jul 2013 20:03:08 +0200

> On 07/10/13 16:18, Eliezer Tamir wrote:
>> Add description for the SO_BUSY_POLL socket option to the socket(7) manpage.
>> 
>> v2
>> fixed typos reported by Rasmus Villemoes
> 
> Eliezer,
> 
> What's the status of this feature. A quick grep seems to show
> that the feature is not yet in mainline. What is the plan?

It's in Linus's tree.
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
