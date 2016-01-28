From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 7/9] net: macb: avoid uninitialized variables
Date: Thu, 28 Jan 2016 17:32:47 +0100
Message-ID: <1593788.TL4Ey44qeU@wuerfel>
References: <1453903507-3427225-1-git-send-email-arnd@arndb.de> <56A8E788.5020802@atmel.com> <56A8EA9F.6070404@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56A8EA9F.6070404@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 27 January 2016 17:04:47 Nicolas Ferre wrote:
> > 
> > Okay Arnd, thanks!
> > 
> > Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>
> 
> Oh, crap: actually this warning has just been fixed by Sudip Mukherjee
> and is already queued by David here:
> https://patchwork.ozlabs.org/patch/572610/
> 
> So, sorry, I've shot too fast: NACK...

Ok, thanks for pointing this out.

	Arnd
