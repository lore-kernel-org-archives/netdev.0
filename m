From: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: RE: [PATCH V3 net-next] net: hns3: Add support to change MTU in
 HNS3 hardware
Date: Mon, 21 Aug 2017 14:32:40 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F93B875655@FRAEML521-MBX.china.huawei.com>
References: <20170821101223.111852-1-salil.mehta@huawei.com>
 <20170821142939.GG1703@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "Zhuangyuzeng (Yisen)" <yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        "lipeng (Y)" <lipeng321-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        "mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linuxarm <linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170821142939.GG1703-g2DYL2Zd6BY@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

> -----Original Message-----
> From: Andrew Lunn [mailto:andrew-g2DYL2Zd6BY@public.gmane.org]
> Sent: Monday, August 21, 2017 3:30 PM
> To: Salil Mehta
> Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org; Zhuangyuzeng (Yisen); lipeng (Y);
> mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-
> kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Linuxarm
> Subject: Re: [PATCH V3 net-next] net: hns3: Add support to change MTU
> in HNS3 hardware
> 
> On Mon, Aug 21, 2017 at 11:12:23AM +0100, Salil Mehta wrote:
> > This patch adds the following support to the HNS3 driver:
> > 1. Support to change the Maximum Transmission Unit of a
> >    of a port in the HNS NIC hardware.
> > 2. Initializes the supported MTU range for the netdevice.
> >
> > Signed-off-by: lipeng <lipeng321-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> > Signed-off-by: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> 
> Hi Salil
> 
> Apart from Leon comments.
> 
> Reviewed-by: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
> 
>     Andrew

I will incorporate Leon's comment and float V4 patch today. Thanks!

Best regards
Salil
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
