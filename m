From: Murali Karicheri <m-karicheri2-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH v7 2/3] net: Add Keystone NetCP ethernet driver
Date: Thu, 11 Dec 2014 09:14:37 -0500
Message-ID: <5489A6CD.20909@ti.com>
References: <1417556503-22290-3-git-send-email-m-karicheri2@ti.com> <20141209.131053.2026868499542642866.davem@davemloft.net> <5488BB96.9070609@ti.com> <20141210.204110.618599360537141819.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20141210.204110.618599360537141819.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 12/10/2014 08:41 PM, David Miller wrote:
> From: Murali Karicheri<m-karicheri2-l0cyMroinI0@public.gmane.org>
> Date: Wed, 10 Dec 2014 16:31:02 -0500
>
>> Are you referring to the static code analyser sparse that is invoked
>> through?
>
> You have to explicitly enable endian checking, it's not on by
> default.
Thanks David and others who responded. Let me do this and resolve any 
warning before the next post.

BTW, could you provide any suggestions that would help us merge this 
series to upstream? This has been sitting on this list for a while now.

Thanks and regards,

-- 
Murali Karicheri
Linux Kernel, Texas Instruments
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
