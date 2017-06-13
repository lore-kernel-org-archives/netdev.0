From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 1/2] mdio_bus: handle only single PHY reset GPIO
Date: Tue, 13 Jun 2017 12:20:29 +0300
Message-ID: <776ffab1-d0a2-093e-17c9-8e023422c1ff@cogentembedded.com>
References: <20170612210547.823996341@cogentembedded.com>
 <12bb1f10-79cc-25a5-1115-69d13c36a68b@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Frank Rowand <frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <12bb1f10-79cc-25a5-1115-69d13c36a68b-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello!

On 6/13/2017 2:43 AM, Florian Fainelli wrote:

> Subject should be: net: phy: Handle only single PHY reset GPIO to be
> consistent with prior submissions,

    With what exactly previous submissions? I'm seeing all kinds of prefixes 
for drivers/net/phy/mdio_bus.c, mine matched Roger's one (as well as my own 
and others').

> and can you also send your patches
> inline using git format-patch + git send-email so it's possible to quote
>  the contents?

    Hm, you're the first complaining about my patches posted with quilt...
Using git adds more efforts on my side (I don't use git for the patch 
development). :-/

> Thanks

MNR, Sergei

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
