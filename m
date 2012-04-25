From: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 09/14] usb/net: rndis: merge media type definitions
Date: Wed, 25 Apr 2012 17:08:40 +0200
Message-ID: <CACRpkdaz4154gTmkEA0=QRb1OvD_cvy25hbTe03J5UUxk8nr0w@mail.gmail.com>
References: <1333874900-5072-1-git-send-email-linus.walleij@linaro.org>
	<20120410093708.7038797wijmbsmos@www.81.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>,
	Haiyang Zhang <haiyangz-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>,
	Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>,
	Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
To: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120410093708.7038797wijmbsmos-tzMWlZeEOor1KXRcyAk9cg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 10, 2012 at 8:37 AM, Jussi Kivilinna
<jussi.kivilinna-E01nCVcF24I@public.gmane.org> wrote:

> NDIS medium type enumeration is not same as NDIS physical medium
> enumeration..
>
> http://msdn.microsoft.com/en-us/library/windows/hardware/ff565910%28v=vs.85%29.aspx
> http://msdn.microsoft.com/en-us/library/windows/hardware/ff569621%28v=vs.85%29.aspx

Aha. I will rework this and post a v2 that make them distinct...

Yours,
Linus Walleij
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
