From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next v4] net: Fix Hisilicon Network Subsystem
 Support Compilation
Date: Mon, 28 Sep 2015 22:34:50 -0700 (PDT)
Message-ID: <20150928.223450.2253763281253460708.davem@davemloft.net>
References: <1443338564-185286-1-git-send-email-huangdaode@hisilicon.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org, galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	catalin.marinas-5wv7dgnIgG8@public.gmane.org, will.deacon-5wv7dgnIgG8@public.gmane.org,
	liguozhu-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org, Yisen.Zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org, dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, kenneth-lee-2012-H32Fclmsjq1BDgjK7y7TUQ@public.gmane.org,
	xuwei5-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org, lisheng011-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
To: huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1443338564-185286-1-git-send-email-huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: huangdaode <huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Date: Sun, 27 Sep 2015 15:22:44 +0800

> This patch fixes the compilation error with arm allmodconfig, this error
> generated due to unavailability of readq() on 32-bit platform which was
> found during net-next daily compilation. In the same time, fix all the
> hns drivers compilation warnings.
> 
> Signed-off-by: huangdaode <huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
> Signed-off-by: zhaungyuzeng <Yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: kenneth Lee <liguozhu-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
> Signed-off-by: yankejian <yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>

Applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
