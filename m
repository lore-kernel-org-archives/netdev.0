From: Kevin Hilman <khilman-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
Subject: Re: [RFC PATCH 01/13] pinctrl: meson: Add GXL pinctrl definitions
Date: Mon, 31 Oct 2016 12:23:54 -0600
Message-ID: <m27f8o2x8l.fsf@baylibre.com>
References: <1477060838-14164-1-git-send-email-narmstrong@baylibre.com>
        <1477060838-14164-2-git-send-email-narmstrong@baylibre.com>
        <CACRpkdZ5VG2NGRh5CmYcYzwCp0LYSsgxHogCFa+6W7BDDBXOYg@mail.gmail.com>
        <b80010f7-196a-abeb-e4a2-5009f3b7f13b@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Carlo Caione <carlo-KA+7E9HrN00dnm+yROfE0A@public.gmane.org>,
        "linux-gpio\@vger.kernel.org" <linux-gpio-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "devicetree\@vger.kernel.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-arm-kernel\@lists.infradead.org"
        <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        "open list\:ARM\/Amlogic Meson..."
        <linux-amlogic-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        "linux-kernel\@vger.kernel.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "netdev\@vger.kernel.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Neil Armstrong <narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <b80010f7-196a-abeb-e4a2-5009f3b7f13b-rdvid1DuHRBWk0Htik3J/w@public.gmane.org> (Neil
        Armstrong's message of "Mon, 31 Oct 2016 10:40:24 +0100")
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Neil Armstrong <narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org> writes:

> On 10/24/2016 03:03 AM, Linus Walleij wrote:
>> On Fri, Oct 21, 2016 at 4:40 PM, Neil Armstrong <narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org> wrote:
>> 
>>> Add support for the Amlogic Meson GXL SoC, this is a partially complete
>>> definition only based on the Amlogic Vendor tree.
>>>
>>> This definition differs a lot from the GXBB and needs a separate entry.
>>>
>>> Signed-off-by: Neil Armstrong <narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
>> 
>> Looks good to me. Tell me when I may apply it, it looks orthogonal
>> to the rest of the patches.
>> 
>> Yours,
>> Linus Walleij
>> 
>
> Hi Linus,
>
> I'm ok to have it applied as soon as possible, but I can send a clean non-rfc patch if needed.
>

Acked-by: Kevin Hilman <khilman-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>

I was hoping to have a bit clearer info from the vendor, but based on
vendor BSP, I think we have most of the info, and can do the minor
fixups if/when we get detailed documentation.

Kevin
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
