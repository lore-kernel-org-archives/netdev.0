From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next 00/12] qed: Add iWARP support for QL4xxxx
Date: Mon, 03 Jul 2017 01:47:08 -0700 (PDT)
Message-ID: <20170703.014708.552467938183415134.davem@davemloft.net>
References: <1498980572-29519-1-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ram.amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org, yuval.mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org,
        ariel.elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1498980572-29519-1-git-send-email-Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Date: Sun, 2 Jul 2017 10:29:20 +0300

> This patch series adds iWARP support to our QL4xxxx networking adapters.
> The code changes span across qed and qedr drivers, but this series contains
> changes to qed only. Once the series is accepted, the qedr series will
> be submitted to the rdma tree.
> There is one additional qed patch which enables the iWARP, this patch is
> delayed until the qedr series will be accepted. 
> 
> The patches were previously sent as an RFC, and these are the first 12
> patches in the RFC series:
> https://www.spinics.net/lists/linux-rdma/msg51416.html
> 
> This series was tested and built against net-next.
> 
> MAINTAINERS file is not updated in this PATCH as there is a pending patch
> for qedr driver update https://patchwork.kernel.org/patch/9752761.

Series applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
