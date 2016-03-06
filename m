From: Leon Romanovsky <leon-2ukJVAZIZ/Y@public.gmane.org>
Subject: Re: [PATCH 0/4] infiniband: hns: Hisilicon RoCE support
Date: Sun, 6 Mar 2016 16:19:07 +0200
Message-ID: <20160306141907.GD13396@leon.nu>
References: <1457080877-13456-1-git-send-email-xavier.huwei@huawei.com>
Reply-To: leon-2ukJVAZIZ/Y@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	gongyangming-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, xiaokun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	tangchaofei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	lisheng011-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, charles.chenxin-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
To: "Wei Hu(Xavier)" <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1457080877-13456-1-git-send-email-xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 04, 2016 at 04:41:13PM +0800, Wei Hu(Xavier) wrote:
> The Hisilicon Network Substem(hns) is a long term evolution IP which is
> supposed to be used in Hisilicon ICT SoC. RoCE is a feature of hns.
> The driver for Hisilicon RoCE engine is a platform driver.
> The driver will support mulitple versions of hns. Currently only "v1"
> for hip06 SOC is supported.
> 
> Wei Hu(Xavier) (4):
>   net: hns: add Hisilicon RoCE support(the dependent routine)
>   infiniband: hns: add Hisilicon RoCE support(binding)
>   infiniband: hns: add Hisilicon RoCE support(driver code)
>   infiniband: hns: add Hisilicon RoCE support(Kconfig)

Please use commonly used in this subsystem titles:
"infiniband: hns: add" -> "IB/hns: Add"

> 
>  .../bindings/infiniband/hisilicon-hns-roce.txt     |   68 +

...^^^... it looks strange.

Thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
