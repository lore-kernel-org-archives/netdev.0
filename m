From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH v8 22/22] MAINTAINERS: Add maintainers for HiSilicon
 RoCE driver
Date: Wed, 25 May 2016 08:19:40 -0700
Message-ID: <1464189580.16344.17.camel@perches.com>
References: <1464188725-42805-1-git-send-email-oulijun@huawei.com>
	 <1464188725-42805-23-git-send-email-oulijun@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, gongyangming-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	xiaokun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, tangchaofei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	charles.chenxin-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
To: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1464188725-42805-23-git-send-email-oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-05-25 at 23:05 +0800, Lijun Ou wrote:
> This patch added maintainers for RoCE driver.

Please add sections in alphabetic order.

> diff --git a/MAINTAINERS b/MAINTAINERS
[]
> @@ -10121,6 +10121,14 @@ W:	http://www.emulex.com
> =A0S:	Supported
> =A0F:	drivers/infiniband/hw/ocrdma/
> =A0
> +HISILICON ROCE DRIVER
> +M:	Wei Hu(Xavier) <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> +M:	Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> +L:	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> +S:	Maintained
> +F:	drivers/infiniband/hw/hns/
> +F:	Documentation/devicetree/bindings/infiniband/hisilicon-hns-roce.t=
xt
> +
> =A0SFC NETWORK DRIVER
> =A0M:	Solarflare linux maintainers=20
> =A0M:	Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
