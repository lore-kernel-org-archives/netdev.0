From: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v3 01/20] net: stmmac: export
 stmmac_set_mac_addr/stmmac_get_mac_addr
Date: Wed, 12 Apr 2017 09:42:57 +0200
Message-ID: <20170412074257.GC11170@Red>
References: <20170403091444.29876-1-clabbe.montjoie@gmail.com>
 <20170403091444.29876-2-clabbe.montjoie@gmail.com>
 <9514c077-1738-ea49-ca18-fbc46bac6144@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org,
        linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org,
        will.deacon-5wv7dgnIgG8@public.gmane.org, alexandre.torgue-qxv4g6HH51o@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Giuseppe CAVALLARO <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <9514c077-1738-ea49-ca18-fbc46bac6144-qxv4g6HH51o@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 03, 2017 at 02:39:03PM +0200, Giuseppe CAVALLARO wrote:
> Hello Alex
> 
> do you can check if this has to be done for ST platforms?
> I do not remember that it was necessary when build as module so
> I cannot expect this should be only for dwmac-sun8i.
> 
> Regards
> peppe
> 

dwmac-sun8i is simply the first "user" of stmmac_[sg]et_mac_addr outside of stmmac-objs

Regards
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
