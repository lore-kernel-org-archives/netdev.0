From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next v8 0/4] net: Add Keystone NetCP ethernet
 driver support
Date: Mon, 19 Jan 2015 15:11:06 -0500 (EST)
Message-ID: <20150119.151106.822126941934010309.davem@davemloft.net>
References: <1421367007-19744-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: m-karicheri2-l0cyMroinI0@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1421367007-19744-1-git-send-email-m-karicheri2-l0cyMroinI0@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Murali Karicheri <m-karicheri2-l0cyMroinI0@public.gmane.org>
Date: Thu, 15 Jan 2015 19:10:03 -0500

> The Network Coprocessor (NetCP) is a hardware accelerator that processes
> Ethernet packets. NetCP has a gigabit Ethernet (GbE) subsystem with a ethernet
> switch sub-module to send and receive packets. NetCP also includes a packet
> accelerator (PA) module to perform packet classification operations such as
> header matching, and packet modification operations such as checksum
> generation. NetCP can also optionally include a Security Accelerator(SA)
> capable of performing IPSec operations on ingress/egress packets.
>     
> Keystone SoC's also have a 10 Gigabit Ethernet Subsystem (XGbE) which
> includes a 3-port Ethernet switch sub-module capable of 10Gb/s and
> 1Gb/s rates per Ethernet port.
>     
> Both GBE and XGBE network processors supported using common driver. It
> is also designed to handle future variants of NetCP.

Series applied to net-next, thanks.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
