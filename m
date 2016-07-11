From: "Wei Hu (Xavier)" <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v11 00/22] Add HiSilicon RoCE driver
Date: Mon, 11 Jul 2016 17:38:39 +0800
Message-ID: <5783691F.6060203@huawei.com>
References: <1467452364-66522-1-git-send-email-oulijun@huawei.com>
 <577F16C1.8090705@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <577F16C1.8090705-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 2016/7/8 10:58, oulijun wrote:
> =E5=9C=A8 2016/7/2 17:39, Lijun Ou =E5=86=99=E9=81=93:
>> The HiSilicon Network Substem is a long term evolution IP which is
>> supposed to be used in HiSilicon ICT SoCs. HNS (HiSilicon Network
>> Sybsystem) also has a hardware support of performing RDMA with
>> RoCEE.
>> The driver for HiSilicon RoCEE(RoCE Engine) is a platform driver and
>> will support mulitple versions of SOCs in future. This version of dr=
iver
>> is meant to support Hip06 SoC(which confirms to RoCEv1 hardware
>> specifications).
>>
>> Changes v10 -> v11:
>> [1/22]:
>> 1. modify the print description of chip don't support roce
>> 2. remove explicit values for enums for patch series
>> [3/22]:
>> 3. remove non-essential headers for patch series
<...>
>>
> Hi, Doug
> We have modified Patch v10 to Patch v11 according to all the reviews =
from Leon Romanovsky, and Patch v11 has been upstreamed,
> hopefully, there will be more reviews.
> Best Regards,
>
> Lijun Ou
Hi, Doug Ledford

     Have you got any time to look at this patchset? Any feedback /=20
comment ?

Many thanks
Wei Hu
> _______________________________________________
> linuxarm mailing list
> linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
> http://rnd-openeuler.huawei.com/mailman/listinfo/linuxarm


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
