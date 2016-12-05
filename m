From: Harini Katakam <harinikatakamlinux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC PATCH 2/2] Documentation: devictree: Add macb mdio bindings
Date: Mon, 5 Dec 2016 08:25:11 +0530
Message-ID: <CAFcVECJRbgAxQMbu7jABHjkiicD1Ysp7WmDMoUzs2P5qn26uqw@mail.gmail.com>
References: <1480326567-6132-1-git-send-email-harinik@xilinx.com> <20161203213553.f3agwvaseufglnq6@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Harini Katakam <harini.katakam-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
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
To: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161203213553.f3agwvaseufglnq6@rob-hp-laptop>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Rob,


Thanks for the review.
On Sun, Dec 4, 2016 at 3:05 AM, Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> On Mon, Nov 28, 2016 at 03:19:27PM +0530, Harini Katakam wrote:
<snip>
>> +Required properties:
>> +- compatible: Should be "cdns,macb-mdio"
>
> Only one version ever? This needs more specific compatible strings.
>

This is part of the Cadence MAC in a way.
I can use revision number from the Cadence spec I was working with.
But it is not necessarily specific that version.

I'll take care of the other comments in the next version.

Regards,
Harini
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
