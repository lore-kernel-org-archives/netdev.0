From: Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v5 09/21] IB/hns: Add hca support
Date: Sat, 30 Apr 2016 07:33:20 +0300
Message-ID: <CAJ3xEMgvcRa=qFDs0wDv25Ue2yw0hQoK_E=01G7zikyr7kLKUw@mail.gmail.com>
References: <1461407219-72027-1-git-send-email-oulijun@huawei.com>
	<1461407219-72027-10-git-send-email-oulijun@huawei.com>
	<20160424075424.GE7974@leon.nu>
	<571F0C04.2010005@huawei.com>
	<20160426141821.GJ7974@leon.nu>
	<20160426142517.GA1937@nanopsycho.orion>
	<57203347.4000107@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>, Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Jiri Pirko <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	gongyangming-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, xiaokun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	tangchaofei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	lisheng011-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, charles.chenxin-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
To: oulijun <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <57203347.4000107-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 27, 2016 at 6:34 AM, oulijun <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org> wrote:
> On 2016/4/26 22:25, Jiri Pirko wrote:
>> Tue, Apr 26, 2016 at 04:18:21PM CEST, leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org wrote:

>>>>     I appreciate your keen eye. this code is meant for ARM64bit therefore should run corretly for 64-bit AARCH64.

>> The driver should run correctly on any arch.

>  Hi Jiri Pirko,
>     Our driver run in ARM64 platform by depending on Kconfig. It will be configure in Kconfig file.

Can you elaborate what design aspects in the driver or anywhere else
should impose that limitation?

Or.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
