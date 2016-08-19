From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next] net: hns: Add reset function support for RoCE
 driver
Date: Fri, 19 Aug 2016 16:58:53 -0700 (PDT)
Message-ID: <20160819.165853.2138490805068691222.davem@davemloft.net>
References: <1471523572-50633-1-git-send-email-oulijun@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
To: oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1471523572-50633-1-git-send-email-oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Date: Thu, 18 Aug 2016 20:32:52 +0800

> It added reset function for RoCE driver. RoCE is a feature of hns.
> In hip06 SoC, in RoCE reset process, it's needed to configure dsaf
> channel reset, port and sl map info. Reset function of RoCE is
> located in dsaf module, we only call it in RoCE driver when needed.
> 
> This patch is used to fix the conflict, please refer to this link:
>   https://www.spinics.net/lists/linux-rdma/msg39114.html
> 
> Signed-off-by: Wei Hu <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Nenglong Zhao <zhaonenglong-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
> Signed-off-by: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Sheng Li <lisheng011-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> Reviewed-by: Yisen Zhuang <yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>

Applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
