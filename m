From: Harini Katakam <harinikatakamlinux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC PATCH 2/2] Documentation: devictree: Add macb mdio bindings
Date: Mon, 5 Dec 2016 08:33:37 +0530
Message-ID: <CAFcVEC+bhLViUxrjn5aZd_fz79SGnhCVOZxL=_3mVA8GxVRCKg@mail.gmail.com>
References: <1480326567-6132-1-git-send-email-harinik@xilinx.com>
 <20161203213553.f3agwvaseufglnq6@rob-hp-laptop> <bfbc84ce-4975-3213-3b46-8c394c717ea9@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Harini Katakam <harini.katakam-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
        Nicolas Ferre <nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        "ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org" <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
        Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        Boris Brezillon <boris.brezillon-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        alexandre.belloni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "michals-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org" <michals-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <bfbc84ce-4975-3213-3b46-8c394c717ea9-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Florian,

On Sun, Dec 4, 2016 at 4:10 AM, Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wro=
te:
> Le 12/03/16 =C3=A0 13:35, Rob Herring a =C3=A9crit :
>> On Mon, Nov 28, 2016 at 03:19:27PM +0530, Harini Katakam wrote:
>>> +- reg: Address and length of the register set of MAC to be used
>>> +- clock-names: Tuple listing input clock names.
>>> +    Required elements: 'pclk', 'hclk'
>>> +    Optional elements: 'tx_clk'
>>> +- clocks: Phandles to input clocks.
>
> You are also missing mandatory properties:
>
> #address-cells =3D <1> and #size-cells =3D <0>
>
> Where is patch 1? Can you make sure you have the same recipient list for
> both patches in this series so we can review both the binding and driver?
>

Thanks for review, I'll update.

I did send the cover letter, patch 1 and 2 to the same recipient list.
I can see them on the mailing list. The first patch is called:
[RFC PATCH 1/2] net: macb: Add MDIO driver for accessing multiple PHY devic=
es
I hope you can find it.

Regards,
Harini
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
