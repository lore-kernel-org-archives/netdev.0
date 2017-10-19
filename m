From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next] qed: Fix iWARP out of order flow
Date: Thu, 19 Oct 2017 12:47:01 +0100 (WEST)
Message-ID: <20171019.124701.29421527567072533.davem@davemloft.net>
References: <1508225005-3572-1-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Manish.Rangankar-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org,
        Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org
To: Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1508225005-3572-1-git-send-email-Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Date: Tue, 17 Oct 2017 10:23:25 +0300

> Out of order flow is not working for iWARP.
> This patch got cut out from initial series that added out
> of order support for iWARP.
> 
> Make out of order code common for iWARP and iSCSI.
> Add new configuration option CONFIG_QED_OOO. Set by
> qedr and qedi Kconfigs.
> 
> Fixes: d1abfd0b4ee2 ("qed: Add iWARP out of order support")
> 
> Signed-off-by: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Manish Rangankar <Manish.Rangankar-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Ariel Elior <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
