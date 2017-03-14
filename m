From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next 01/12] net: phy: bcm-phylib: replace obsolete EEE
 macro references
Date: Mon, 13 Mar 2017 17:49:17 -0700
Message-ID: <443a2d7f-b625-9de2-d9f8-385f3c6952cd@gmail.com>
References: <20170314004142.4746-1-opendmb@gmail.com>
 <20170314004142.4746-2-opendmb@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        rafal-g1n6cQUeyibVItvQsEIGlw@public.gmane.org, xow-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, joel-U3u1mxZcP9KHXe+LvDLADg@public.gmane.org,
        jon.mason-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        pgynther-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, jaedon.shin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Doug Berger <opendmb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170314004142.4746-2-opendmb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03/13/2017 05:41 PM, Doug Berger wrote:
> The macros MDIO_AN_EEE_ADV_100TX and MDIO_AN_EEE_ADV_1000T are now
> considered obsolete and are replaced in the kernel with the generic
> macros MDIO_EEE_100TX and MDIO_EEE_1000T respectively.
> 
> Signed-off-by: Doug Berger <opendmb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Reviewed-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
