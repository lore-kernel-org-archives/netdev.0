From: Murali Karicheri <m-karicheri2-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH net-next v8 0/4] net: Add Keystone NetCP ethernet driver
 support
Date: Tue, 20 Jan 2015 10:53:36 -0500
Message-ID: <54BE7A00.2020205@ti.com>
References: <1421367007-19744-1-git-send-email-m-karicheri2@ti.com> <20150119.151106.822126941934010309.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150119.151106.822126941934010309.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 01/19/2015 03:11 PM, David Miller wrote:
> From: Murali Karicheri<m-karicheri2-l0cyMroinI0@public.gmane.org>
> Date: Thu, 15 Jan 2015 19:10:03 -0500
>
>> The Network Coprocessor (NetCP) is a hardware accelerator that processes
>> Ethernet packets. NetCP has a gigabit Ethernet (GbE) subsystem with a ethernet
>> switch sub-module to send and receive packets. NetCP also includes a packet
>> accelerator (PA) module to perform packet classification operations such as
>> header matching, and packet modification operations such as checksum
>> generation. NetCP can also optionally include a Security Accelerator(SA)
>> capable of performing IPSec operations on ingress/egress packets.
>>
>> Keystone SoC's also have a 10 Gigabit Ethernet Subsystem (XGbE) which
>> includes a 3-port Ethernet switch sub-module capable of 10Gb/s and
>> 1Gb/s rates per Ethernet port.
>>
>> Both GBE and XGBE network processors supported using common driver. It
>> is also designed to handle future variants of NetCP.
>
> Series applied to net-next, thanks.
David,

Thanks a lot for applying this series. This helps us move forward to 
work on the next set of patches.

Thanks
-- 
Murali Karicheri
Linux Kernel, Texas Instruments
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
