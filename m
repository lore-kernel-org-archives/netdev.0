From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] net: phy: dp83867: Port mirroring support in the DP83867
 TI's PHY driver
Date: Wed, 1 Feb 2017 11:05:12 -0800
Message-ID: <2f3766f0-42df-6aab-dda1-14022c57fb30@gmail.com>
References: <1485960215-5148-1-git-send-email-lukma@denx.de>
 <20170201171610.GC7395@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>,
        Karicheri Muralidharan <m-karicheri2-l0cyMroinI0@public.gmane.org>,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Eric Engestrom <eric-op+oiCINJLTt9jDmeYuA0g@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Kishon Vijay Abraham I <kishon-l0cyMroinI0@public.gmane.org>,
        Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>, Lukasz Majewski <lukma-ynQEQJNshbs@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170201171610.GC7395-g2DYL2Zd6BY@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 02/01/2017 09:16 AM, Andrew Lunn wrote:
> On Wed, Feb 01, 2017 at 03:43:35PM +0100, Lukasz Majewski wrote:
>> This patch adds support for enabling or disabling the port mirroring
>> feature of the DP83867 TI's PHY device.
>>
>> One use case is when bootstrap configuration enables this feature (because
>> of e.g. LED wiring) so then one needs to disable it in software
>> (u-boot/Linux).
> 
> Hi Lukasz
> 
> How does this differ from "enet-phy-lane-swap"?

Same here, I am confused about what port mirroring could be meaning here
and if we can find a better way to describe what is being added. Thanks!
-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
