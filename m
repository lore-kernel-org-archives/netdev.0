From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [net-next PATCHv6 0/2] net: ethernet: Socionext Netsec
Date: Wed, 30 Aug 2017 21:06:25 -0700
Message-ID: <27A7C5A5-AFF4-49F3-B0DF-7F53283EC2A4@gmail.com>
References: <1504088657-6102-1-git-send-email-jaswinder.singh@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: mark.rutland-5wv7dgnIgG8@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, patches-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org,
        Jassi Brar <jaswinder.singh-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
        andy-/Zus8d0mwwtBDgjK7y7TUQ@public.gmane.org
To: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        Jassi Brar <jassisinghbrar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1504088657-6102-1-git-send-email-jaswinder.singh-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On August 30, 2017 3:24:17 AM PDT, Jassi Brar <jassisinghbrar@gmail=2Ecom> =
wrote:
>Hello,
>
>The OGMA/Netsec controller is used in latest SoC from
>Socionext/Fujitsu=2E
>
>I am refreshing the patchset by basically using official name of the IP
>from 'OGMA' to 'Netsec'=2E And the company is renamed too, from Fujitsu
>to Socionext to better reflect the reality=2E
>
> I have addressed comments (that could be) on the last revision -->
>https://patchwork=2Ekernel=2Eorg/patch/4540651/
>
> Of course, I have scanned changes to the drivers/net/ethernet since
>last submission and integrated whichever applicable and rebased the
>driver on top of last rc=2E

It does not appear to be at first glance, but I will just ask anyways, thi=
s is not yet another variant of stmmac glued just a little bit differently =
into the SoC right?

Will take a closer look at the register set and driver tomorrow=2E Thanks

--=20
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
