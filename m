From: Eliezer Tamir <eliezer.tamir-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [PATCH v2] socket.7: add description for SO_BUSY_POLL
Date: Wed, 10 Jul 2013 21:56:37 +0300
Message-ID: <51DDAE65.7040604@linux.intel.com>
References: <20130710141835.15799.61657.stgit@ladj378.jer.intel.com> <51DDA1DC.2020306@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Eliezer Tamir <eliezer-rsSRdLmRgNEQhDRD3CWCHA@public.gmane.org>
To: Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <51DDA1DC.2020306-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 10/07/2013 21:03, Michael Kerrisk wrote:
> On 07/10/13 16:18, Eliezer Tamir wrote:
>> Add description for the SO_BUSY_POLL socket option to the socket(7) manpage.
> 
> What's the status of this feature. A quick grep seems to show
> that the feature is not yet in mainline. What is the plan?

The basic code is already in Linus' tree. there were request to rename
things. The current name for the socket option is SO_LL but a patche to
rename it to SO_BUSY_POLL were sent to net-dev.

http://patchwork.ozlabs.org/patch/258065/

If you want me to notify you when the change hits Linus' tree I can do that.

-Eliezer
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
