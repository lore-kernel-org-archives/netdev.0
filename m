From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH -net-next 3/4] firmware: convert tg3 driver to
 request_firmware()
Date: Mon, 05 Jan 2009 14:22:31 +0000
Message-ID: <1231165351.8286.279.camel@macbook.infradead.org>
References: <1230626497.24796.26.camel@jaswinder.satnam>
	 <49620AFE.6040409@hartkopp.net>
	 <3f9a31f40901050612v700d2542r1e3e400bf0fe3d33@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Oliver Hartkopp <oliver@hartkopp.net>,
	Jaswinder Singh Rajput <jaswinder@infradead.org>,
	davem@redhat.com, jgarzik@redhat.com,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-next@vger.kernel.org,
	mchan@broadcom.com, Alan Cox <alan@lxorguk.ukuu.org.uk>
To: Jaswinder Singh Rajput <jaswinderlinux@gmail.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <3f9a31f40901050612v700d2542r1e3e400bf0fe3d33@mail.gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2009-01-05 at 19:42 +0530, Jaswinder Singh Rajput wrote:
> On Mon, Jan 5, 2009 at 6:58 PM, Oliver Hartkopp <oliver@hartkopp.net> wrote:
> > 077f849de42e58172e25ccb24df4c1a13e82420c ("firmware: convert tg3 driver to
> > request_firmware()")
> >
> > and i discovered that
> >
> > 1. I needed to compile the tg3 driver as *module* now as it was not able to
> > read the firmware when built-in.
> >
> 
> Please compile it as build in.
> 
> David Woodhouse: Do you have any plans to support firmware by using modules.

Que?

-- 
dwmw2
