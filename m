From: Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH 0/2] net: phy: dp83867: workaround incorrect RX_CTRL pin
 strap
Date: Wed, 5 Jul 2017 10:49:37 +0530
Message-ID: <b1169d1b-3129-850a-2137-4606e1756939@ti.com>
References: <cover.1499162046.git.nsekhar@ti.com>
 <20170704144752.GB10312@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Device Tree Mailing List <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Tony Lindgren <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>,
        Linux OMAP Mailing List <linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170704144752.GB10312-g2DYL2Zd6BY@public.gmane.org>
Content-Language: en-US
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

On Tuesday 04 July 2017 08:17 PM, Andrew Lunn wrote:
> On Tue, Jul 04, 2017 at 04:23:22PM +0530, Sekhar Nori wrote:
>> Hi,
>>
>> This patch series adds workaround for incorrect RX_CTRL pin strap
>> setting that can be found on some TI boards.
> 
> Hi Sekhar
> 
> Do you plan to post some DT patches to make use of this? It would be
> good to seem them as well.

Actually I ended up posting those prior to this series (done in error)
and have promised Tony a resend once this is accepted.

http://www.spinics.net/lists/devicetree/msg183487.html

I will Cc the same audience on the resend.

Thanks,
Sekhar
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
