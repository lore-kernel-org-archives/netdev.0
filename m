From: Santosh Shilimkar <santosh.shilimkar-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH v4 2/3] net: Add Keystone NetCP ethernet driver
Date: Thu, 25 Sep 2014 13:06:26 -0400
Message-ID: <54244B92.4020004@ti.com>
References: <1411653805-29257-1-git-send-email-santosh.shilimkar@ti.com>	 <1411653805-29257-3-git-send-email-santosh.shilimkar@ti.com> <1411655363.4026.13.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org" <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Nair, Sandeep" <sandeep_n-l0cyMroinI0@public.gmane.org>
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1411655363.4026.13.camel@joe-AO725>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thursday 25 September 2014 10:29 AM, Joe Perches wrote:
> On Thu, 2014-09-25 at 10:03 -0400, Santosh Shilimkar wrote:
>> From: Sandeep Nair <sandeep_n-l0cyMroinI0@public.gmane.org>
>>
>> The network coprocessor (NetCP) is a hardware accelerator that processes
>> Ethernet packets. NetCP has a gigabit Ethernet (GbE) subsystem with a ethernet
>> switch sub-module to send and receive packets. NetCP also includes a packet
>> accelerator (PA) module to perform packet classification operations such as
>> header matching, and packet modification operations such as checksum
>> generation. NetCP can also optionally include a Security Accelerator(SA)
>> capable of performing IPSec operations on ingress/egress packets.
> 
> Some checkpatch trivia you might consider:
Sure. I fold that in. Thanks !!

regards,
Santosh

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
