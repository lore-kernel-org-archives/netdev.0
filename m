From: Jose Abreu <Jose.Abreu-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH net-next 2/2] bindings: net: stmmac: Add documentation for
 TSN parameters
Date: Thu, 26 Oct 2017 10:19:24 +0100
Message-ID: <10e2834b-eaa5-ad37-5fca-1e4b1f9b0d53@synopsys.com>
References: <cover.1508938927.git.joabreu@synopsys.com>
 <ef1d220cf792c74ae278e0200ca4763f9ab62d3e.1508938927.git.joabreu@synopsys.com>
 <c2a4a435-0b0b-4fa3-a69a-280f6d0c6427@gmail.com>
 <23152048-09fe-2950-e1ff-8cf90ca3f465@synopsys.com>
 <20171026090308.GD20299@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Joao Pinto <Joao.Pinto-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>,
        Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        Alexandre Torgue <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20171026090308.GD20299-g2DYL2Zd6BY@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

On 26-10-2017 10:03, Andrew Lunn wrote:
>> These parameters may also need to change in runtime depending on
>> the scheduled traffic. Unfortunately, net subsystem does not yet
>> support TSN so this will have to wait and for now we will use
>> fixed parameters.
> Hi Jose
>
> what you should do is help Linux get support for TSN. Please take part
> in this discussion:
>
> https://urldefense.proofpoint.com/v2/url?u=https-3A__patchwork.ozlabs.org_cover_808504_&d=DwIBAg&c=DPL6_X_6JkXFx7AXWqB0tg&r=WHDsc6kcWAl4i96Vm5hJ_19IJiuxx_p_Rzo2g-uHDKw&m=8yzdm5iHyWm9cVsYIYUtQNul5WnLO4nLnIxb3WDu-WU&s=6UJ2YJm5jXq6vTWpNRwRzNEuukPboceO61DQgDIpSj0&e=

Seems like I don't have this thread saved here. Can you please
add me in the thread?

Thanks and best regards,
Jose Miguel Abreu

>
> Test the RFC, make sure the concepts will work for your hardware. Make
> you hardware work with these RFC patches. Help drive TSN forward. Once
> the core TSN code lands, then you can post patches for your driver.
>
>     Andrew

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
