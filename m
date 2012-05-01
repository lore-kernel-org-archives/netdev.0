From: Haiyang Zhang <haiyangz-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>
Subject: RE: [PATCH 02/13 v4] usb/net: rndis: break out <linux/rndis.h>
 defines
Date: Tue, 1 May 2012 19:42:43 +0000
Message-ID: <A1F3067C9B68744AA19F6802BAB8FFDC0DD3CAE5@TK5EX14MBXC221.redmond.corp.microsoft.com>
References: <1335896546-13315-1-git-send-email-linus.walleij@linaro.org>
	<A1F3067C9B68744AA19F6802BAB8FFDC0DD3CAAA@TK5EX14MBXC221.redmond.corp.microsoft.com>
 <CACRpkdZLg5f9uWrT1hYSWhiL-i-=NSUtuPAGKrWcC4+LZs5ACA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>,
	Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>,
	Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>,
	Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
To: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CACRpkdZLg5f9uWrT1hYSWhiL-i-=NSUtuPAGKrWcC4+LZs5ACA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Language: en-US
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Linus Walleij [mailto:linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org]
> Sent: Tuesday, May 01, 2012 3:09 PM
> To: Haiyang Zhang
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Greg Kroah-Har=
tman;
> David S. Miller; Felipe Balbi; Jussi Kivilinna; Wei Yongjun; Ben Hutc=
hings
> Subject: Re: [PATCH 02/13 v4] usb/net: rndis: break out <linux/rndis.=
h>
> defines
>=20
> On Tue, May 1, 2012 at 8:54 PM, Haiyang Zhang <haiyangz-0li6OtcxBFHby3iVrkZq2A@public.gmane.org=
>
> wrote:
>=20
> >> ChangeLog v2->v3:
> >> - Squashed subsequent patch removing duplicate entries into
> >> =A0 this patch so it's bisectable without any compilation warnings=
=2E
> >
> > I have not reviewed this version yet.
> >
> > Also, I think you should merge the "ChangeLog v2->v3" into the patc=
h
> > comments. Don't need to say "The compilation screams about double-
> defines
> > all over the place" any more.
>=20
> This one is completely bogus, please review the v4 versions of the
> patches instead. I was halfway on this one and screwed it up
> somehow, I've had better days :-(

Yes, I'm replying to your v4 patch. It contains the "ChangeLog v2->v3",=
 and
still says "The compilation screams about double-defines all over the p=
lace"
in the comments.

Thanks,
- Haiyang


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
