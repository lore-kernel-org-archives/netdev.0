From: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
Subject: Re: [PATCH] net/9p: convert to new CQ API
Date: Sun, 28 Feb 2016 17:04:08 +0100
Message-ID: <20160228160408.GA23421@lst.de>
References: <1456565151-27115-1-git-send-email-hch@lst.de> <1456565151-27115-2-git-send-email-hch@lst.de> <56D2D413.7080008@dev.mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>,
	v9fs-developer-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Sagi Grimberg <sagig-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <56D2D413.7080008-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 28, 2016 at 01:03:47PM +0200, Sagi Grimberg wrote:
>
>> Trivial conversion to the new RDMA CQ API.
>
> Looks nice and simple :)
>
> But I think that the fact that CQ processing is now
> done in soft-IRQ (which is an improvement!) needs to
> be documented.

Yeah, I meant to do that, but ended up beeing lazy as usual :)
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
