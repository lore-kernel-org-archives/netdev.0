From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH 00/14] usb/net: rndis: first step toward consolidation
Date: Wed, 18 Apr 2012 13:17:34 +0000
Message-ID: <A1F3067C9B68744AA19F6802BAB8FFDC0DD33174@TK5EX14MBXC221.redmond.corp.microsoft.com>
References: <1333874813-3861-1-git-send-email-linus.walleij@linaro.org>
	<A1F3067C9B68744AA19F6802BAB8FFDC0DD215D0@TK5EX14MBXC222.redmond.corp.microsoft.com>
 <CACRpkdZ79RtQDeQnFczsH8noX01Qp5cmAPysVs-5v=Nb=aBw=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Felipe Balbi <balbi@ti.com>,
	Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	Ben Hutchings <ben@decadent.org.uk>
To: Linus Walleij <linus.walleij@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe005.messaging.microsoft.com ([213.199.154.208]:26812
	"EHLO am1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753079Ab2DRNRp convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Apr 2012 09:17:45 -0400
In-Reply-To: <CACRpkdZ79RtQDeQnFczsH8noX01Qp5cmAPysVs-5v=Nb=aBw=Q@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Linus Walleij [mailto:linus.walleij@linaro.org]
> Sent: Wednesday, April 18, 2012 8:26 AM
> To: Haiyang Zhang
> Cc: netdev@vger.kernel.org; linux-usb@vger.kernel.org; Greg Kroah-
> Hartman; David S. Miller; Felipe Balbi; Jussi Kivilinna; Wei Yongjun; Ben
> Hutchings
> Subject: Re: [PATCH 00/14] usb/net: rndis: first step toward consolidation
> 
> On Sun, Apr 8, 2012 at 3:58 PM, Haiyang Zhang <haiyangz@microsoft.com>
> wrote:
> > _______________________________________
> >> From: Linus Walleij [linus.walleij@linaro.org]
> >> Sent: Sunday, April 08, 2012 4:46 AM
> >> To: netdev@vger.kernel.org; linux-usb@vger.kernel.org; Greg
> >> Kroah-Hartman; David S. Miller; Felipe Balbi
> >> Cc: Jussi Kivilinna; Haiyang Zhang; Wei Yongjun; Ben Hutchings; Linus
> >> Walleij
> >> Subject: [PATCH 00/14] usb/net: rndis: first step toward
> >> consolidation
> >
> >> So if you like this, let's proceed, but if you're all in "I wanna
> >> keep this one implementation in my corner" I'll just give up right now.
> >
> >> So: what do you think?
> >
> > I will test this soon.
> 
> Ping on this... any testing so far?

I saw Jussi Kivilinna <jussi.kivilinna@mbnet.fi>'s comments saying it does not
work. And your patches are in "changes requested" state. So I'm waiting for
your updated patches before testing.

Thanks,
- Haiyang
