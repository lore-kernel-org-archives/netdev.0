From: Jassi Brar <jassisinghbrar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [net-next PATCHv6 0/2] net: ethernet: Socionext Netsec
Date: Thu, 31 Aug 2017 12:01:37 +0530
Message-ID: <CABb+yY0r8ZgeYTdmYqTd3RhUnr1ufOaUUe3+81Q2JKm+xY8PRQ@mail.gmail.com>
References: <1504088657-6102-1-git-send-email-jaswinder.singh@linaro.org> <27A7C5A5-AFF4-49F3-B0DF-7F53283EC2A4@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
        <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Devicetree List <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        "arnd-r2nGTMty4D4@public.gmane.org" <arnd-r2nGTMty4D4@public.gmane.org>,
        "patches-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org" <patches-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Jassi Brar <jaswinder.singh-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Andy Green <andy-/Zus8d0mwwtBDgjK7y7TUQ@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <27A7C5A5-AFF4-49F3-B0DF-7F53283EC2A4-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 31, 2017 at 9:36 AM, Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On August 30, 2017 3:24:17 AM PDT, Jassi Brar <jassisinghbrar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>>Hello,
>>
>>The OGMA/Netsec controller is used in latest SoC from
>>Socionext/Fujitsu.
>>
>>I am refreshing the patchset by basically using official name of the IP
>>from 'OGMA' to 'Netsec'. And the company is renamed too, from Fujitsu
>>to Socionext to better reflect the reality.
>>
>> I have addressed comments (that could be) on the last revision -->
>>https://patchwork.kernel.org/patch/4540651/
>>
>> Of course, I have scanned changes to the drivers/net/ethernet since
>>last submission and integrated whichever applicable and rebased the
>>driver on top of last rc.
>
> It does not appear to be at first glance, but I will just ask anyways, this is not yet another variant of stmmac glued just a little bit differently into the SoC right?
>
Sorry, no idea. I will be glad if we could reuse existing code.

Thanks.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
