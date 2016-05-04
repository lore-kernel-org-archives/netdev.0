From: oulijun <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v6 00/21] Add HiSilicon RoCE driver
Date: Wed, 4 May 2016 19:31:31 +0800
Message-ID: <5729DD93.3000500@huawei.com>
References: <1461845396-61306-1-git-send-email-oulijun@huawei.com>
 <20160503184834.GD29160@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	<hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	<ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<gongyangming-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <xiaokun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<tangchaofei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<charles.chenxin-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160503184834.GD29160-2ukJVAZIZ/Y@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2016/5/4 2:48, Leon Romanovsky wrote:
> On Thu, Apr 28, 2016 at 08:09:35PM +0800, Lijun Ou wrote:
>> The HiSilicon Network Substem is a long term evolution IP which is
>> supposed to be used in HiSilicon ICT SoCs. HNS (HiSilicon Network
>> Sybsystem) also has a hardware support of performing RDMA with
>> RoCEE.
>> The driver for HiSilicon RoCEE(RoCE Engine) is a platform driver and
>> will support mulitple versions of SOCs in future. This version of driver
>> is meant to support Hip06 SoC(which confirms to RoCEEv1 hardware
>> specifications).
> 
> Please read Dave's comment [1], it is valuable for your code as
> well.
> 
> * Please use 'bool' and "true/false"
> 
Yes, i see. thanks

Thanks
Lijun Ou
> [1] http://marc.info/?l=linux-rdma&m=146229367301442&w=2
> 
> Thanks
> 


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
