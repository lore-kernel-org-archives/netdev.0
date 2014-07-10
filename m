From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 1/2] net: davinci_mdio: reuse for keystone2 arch
Date: Thu, 10 Jul 2014 12:39:00 -0700 (PDT)
Message-ID: <20140710.123900.1696373067218564684.davem@davemloft.net>
References: <1404911451-9921-2-git-send-email-grygorii.strashko@ti.com>
	<20140709.165232.539576872991411664.davem@davemloft.net>
	<53BE8DF7.9090303@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, santosh.shilimkar-l0cyMroinI0@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, prabhakar.csengg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, nsekhar-l0cyMroinI0@public.gmane.org,
	robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
To: grygorii.strashko-l0cyMroinI0@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <53BE8DF7.9090303-l0cyMroinI0@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
Date: Thu, 10 Jul 2014 15:58:31 +0300

> Hi David,
> 
> On 07/10/2014 02:52 AM, David Miller wrote:
>> From: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
>> Date: Wed, 9 Jul 2014 16:10:50 +0300
>> 
>>>   Required properties:
>>> -- compatible		: Should be "ti,davinci_mdio"
>>> +- compatible		: Should be "ti,davinci_mdio" or "ti,keystone-mdio"
>> 
>> Why the inconsistency in naming schemes?  I don't see any reason
>> to be different wrt. "_" vs. "-" in the name string.
>> 
> 
> Hm. Looks like the common way is to use "-", but I can rename it if you insist.

I'm just saying, is there a strong reason to be inconsistent?
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
