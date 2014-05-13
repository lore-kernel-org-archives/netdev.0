From: Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH v1 for-next 0/3] IB: Use GFP_NOIO calls in IPoIB connected
 mode TX path
Date: Tue, 13 May 2014 13:38:42 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1405131338030.16459@pobox.suse.cz>
References: <1399810512-30774-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, amirv-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, Mel Gorman <mgorman-l3A5Bk7waGM@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1399810512-30774-1-git-send-email-ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, 11 May 2014, Or Gerlitz wrote:

> This series is a refactored form of the one posted by Jiri Kosina 
> to LKML and netdev according to the discussion that followed
> and the guidelines you provided here https://lkml.org/lkml/2014/3/5/250
> 
> Basically, the functionality changes introduced by this series fully 
> reside on the IB side of things, so I am only posting the actual patches 
> to linux-rdma with CC on the cover-letter to the lists that were on V0.

Thanks, I am fine with my Signoff on that.

Roland, is this going to be merged by you, or should this go to DaveM 
directly?

Thanks,

-- 
Jiri Kosina
SUSE Labs
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
