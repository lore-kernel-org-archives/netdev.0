From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: "rfkill: Add rfkill-any LED trigger" causes deadlock
Date: Tue, 20 Dec 2016 08:47:06 +0100
Message-ID: <1482220026.16460.0.camel@sipsolutions.net>
References: <20161216163707.GA2629@gmail.com>
         <CACpa5=_chGuU3zVcVR3nkNySwz1cGAQTs39v+BjwcDNSvOqhTw@mail.gmail.com>
         <1482137772.31461.1.camel@sipsolutions.net>
         <20161219140115.GA18194@kmp-mobile.hq.kempniu.pl>
         (sfid-20161219_150121_414538_6E38332A)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?Q?=D0=9C=D0=B8=D1=85=D0=B0=D0=B8=D0=BB_?=
         =?UTF-8?Q?=D0=9A=D1=80=D0=B8=D0=BD=D0=BA=D0=B8=D0=BD?=
        <krinkin.m.u-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: =?UTF-8?Q?Micha=C5=82_K=C4=99pie=C5=84?= <kernel-ePNcKBjznIDVItvQsEIGlw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161219140115.GA18194-d0zqvqtRkg7MisJl3QRgO5JNpPtI3pG4@public.gmane.org> (sfid-20161219_150121_414538_6E38332A)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


> Just to ensure things get cleaned up properly, as of now it looks
> like you only reverted patch 2/2 of my v2 and Arnd's fix to patch
> 1/2, not patch 1/2 itself.

Oops. I've fixed that up to only revert your patch - I wanted the
revert in the tree to document the issue, rather than just dropping the
patch entirely. Thanks for noticing that mistake.

johannes
