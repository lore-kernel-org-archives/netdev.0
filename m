From: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 02/13 v4] usb/net: rndis: break out <linux/rndis.h> defines
Date: Tue, 1 May 2012 21:09:28 +0200
Message-ID: <CACRpkdZLg5f9uWrT1hYSWhiL-i-=NSUtuPAGKrWcC4+LZs5ACA@mail.gmail.com>
References: <1335896546-13315-1-git-send-email-linus.walleij@linaro.org>
	<A1F3067C9B68744AA19F6802BAB8FFDC0DD3CAAA@TK5EX14MBXC221.redmond.corp.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>,
	Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>,
	Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>,
	Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
To: Haiyang Zhang <haiyangz-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <A1F3067C9B68744AA19F6802BAB8FFDC0DD3CAAA-Jfd81uAzPQthtgIzimG1dFir+X/St4rqwBk/1ggFUS45P9zcU8sUGwC/G2K4zDHf@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, May 1, 2012 at 8:54 PM, Haiyang Zhang <haiyangz-0li6OtcxBFHby3iVrkZq2A@public.gmane.org> =
wrote:

>> ChangeLog v2->v3:
>> - Squashed subsequent patch removing duplicate entries into
>> =A0 this patch so it's bisectable without any compilation warnings.
>
> I have not reviewed this version yet.
>
> Also, I think you should merge the "ChangeLog v2->v3" into the patch
> comments. Don't need to say "The compilation screams about double-def=
ines
> all over the place" any more.

This one is completely bogus, please review the v4 versions of the
patches instead. I was halfway on this one and screwed it up
somehow, I've had better days :-(

Thanks,
Linus Walleij
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
