From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v3] ethernet :mellanox :mlx4: Replace pci_pool_alloc by
 pci_pool_zalloc
Date: Wed, 30 Nov 2016 14:57:19 -0500 (EST)
Message-ID: <20161130.145719.1474392379616253065.davem@davemloft.net>
References: <20161129194611.GA4088@jordon-HP-15-Notebook-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org, yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        sahu.rameshwar73-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: jrdr.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161129194611.GA4088@jordon-HP-15-Notebook-PC>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Souptick Joarder <jrdr.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Wed, 30 Nov 2016 01:16:12 +0530

> In mlx4_alloc_cmd_mailbox(), pci_pool_alloc() followed by memset will be
> replaced by pci_pool_zalloc()
> 
> Signed-off-by: Souptick joarder <jrdr.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
