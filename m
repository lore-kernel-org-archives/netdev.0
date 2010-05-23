From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] net: mac8390 - Sort out memory/MMIO accesses and casts
	(was: Re: drivers/net/mac8390.c: Remove useless memcpy casting)
Date: Sun, 23 May 2010 15:15:16 +0200
Message-ID: <AANLkTikexlmuunBQ-ydNaD8fkKcLmrsfJSEgvyMJdNqU@mail.gmail.com>
References: <l2k10f740e81004151234t3004275az36e7873493067a8a@mail.gmail.com>
	 <alpine.OSX.2.00.1004161206300.271@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Joe Perches <joe@perches.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"Linux/m68k" <linux-m68k@vger.kernel.org>
To: Finn Thain <fthain@telegraphics.com.au>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <alpine.OSX.2.00.1004161206300.271@localhost>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 16, 2010 at 04:14, Finn Thain <fthain@telegraphics.com.au> wrote:
> On Thu, 15 Apr 2010, Geert Uytterhoeven wrote:
>> On Mon, Mar 8, 2010 at 18:16, Joe Perches <joe@perches.com> wrote:
>> > Thanks, I'll submit a patch to fix it by tomorrow or so.
>>
>> It hasn't been fixed yet.
>
> Thanks for taking care of this, Geert.
>
>> But here's a better solution. I do not have the hardware to test it,
>> though. Finn, does it {look OK,work}?
>
> It looks fine. I can't test it right now, but I will do so when I get the
> opportunity.

Any news from the test front?

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds
