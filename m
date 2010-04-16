From: Finn Thain <fthain@telegraphics.com.au>
Subject: Re: [PATCH] net: mac8390 - Sort out memory/MMIO accesses and casts
 (was: Re: drivers/net/mac8390.c: Remove useless memcpy casting)
Date: Fri, 16 Apr 2010 12:14:02 +1000 (EST)
Message-ID: <alpine.OSX.2.00.1004161206300.271@localhost>
References: <l2k10f740e81004151234t3004275az36e7873493067a8a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Joe Perches <joe@perches.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux/m68k <linux-m68k@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <l2k10f740e81004151234t3004275az36e7873493067a8a@mail.gmail.com>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Thu, 15 Apr 2010, Geert Uytterhoeven wrote:

> On Mon, Mar 8, 2010 at 18:16, Joe Perches <joe@perches.com> wrote:
>
> > Thanks, I'll submit a patch to fix it by tomorrow or so.
> 
> It hasn't been fixed yet.

Thanks for taking care of this, Geert.

> But here's a better solution. I do not have the hardware to test it, 
> though. Finn, does it {look OK,work}?

It looks fine. I can't test it right now, but I will do so when I get the 
opportunity.

Finn
