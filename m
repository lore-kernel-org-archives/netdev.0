From: Don Baton <batnnubv-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v9 04/10] arm: dts: sunxi: h3/h5: represent the mdio
 switch used by sun8i-h3-emac
Date: Thu, 26 Oct 2017 12:56:30 +0300
Message-ID: <CACY=2cmXHQYqMdugEjrAb9gv-7pQ9mSuN4LADdyb=kPyhGnsXA@mail.gmail.com>
References: <20171024175714.15840-1-clabbe.montjoie@gmail.com>
 <20171024175714.15840-5-clabbe.montjoie@gmail.com> <20171026095411.GJ20299@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
        mark.rutland-5wv7dgnIgG8@public.gmane.org, maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org,
        wens-jdAy2FN1RRM@public.gmane.org, linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org,
        will.deacon-5wv7dgnIgG8@public.gmane.org, peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
        alexandre.torgue-qxv4g6HH51o@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20171026095411.GJ20299-g2DYL2Zd6BY@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2017-10-26 12:54 GMT+03:00, Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>:
> On Tue, Oct 24, 2017 at 07:57:08PM +0200, Corentin Labbe wrote:
>> Since dwmac-sun8i could use either an integrated PHY or an external PHY
>> (which could be at same MDIO address), we need to represent this
>> selection
>> by a MDIO switch.
>>
>> Signed-off-by: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>
> Reviewed-by: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
>
>     Andrew
>
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
