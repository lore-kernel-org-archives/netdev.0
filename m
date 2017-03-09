From: Kyle McMartin <kyle-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [PATCH linux-firmware] qed: Add firmware 8.15.3.0
Date: Thu, 9 Mar 2017 10:55:07 -0800
Message-ID: <20170309185507.GG13400@bombadil.infradead.org>
References: <1489053649-12108-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-firmware-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
To: Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1489053649-12108-1-git-send-email-Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 09, 2017 at 12:00:49PM +0200, Yuval Mintz wrote:
> This new firmware for the qed* adapters fixes multiple issues:
>  - Prevent accidental drops in Tx-switching between VFs.
>  - Corrct VF cleanup for higher VFs.
>  - Better handling of RoCE error flows.
>  - MR registration/deregistration corrections.
>  - Prevent possible HW attention during offloaded TCP teardown.
>  - Corrections to iSCSI retransmit flows.
> 
> In addition, this firmware is a requirement for supporting the
> QL41xxx series of adapters, as it contains the necessary init
> and firmware logic for those.
> 
> Signed-off-by: Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>

applied, thanks Yuval.

regards, --kyle
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
