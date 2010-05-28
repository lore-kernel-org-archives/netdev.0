From: Finn Thain <fthain@telegraphics.com.au>
Subject: Re: [PATCH] net: mac8390 - Sort out memory/MMIO accesses and casts
 (was: Re: drivers/net/mac8390.c: Remove useless memcpy casting)
Date: Sat, 29 May 2010 03:21:35 +1000 (EST)
Message-ID: <alpine.OSX.2.00.1005290312230.691@localhost>
References: <l2k10f740e81004151234t3004275az36e7873493067a8a@mail.gmail.com>  <alpine.OSX.2.00.1004161206300.271@localhost> <AANLkTikexlmuunBQ-ydNaD8fkKcLmrsfJSEgvyMJdNqU@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Joe Perches <joe@perches.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux/m68k <linux-m68k@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <AANLkTikexlmuunBQ-ydNaD8fkKcLmrsfJSEgvyMJdNqU@mail.gmail.com>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Sun, 23 May 2010, Geert Uytterhoeven wrote:

> >> But here's a better solution. I do not have the hardware to test it, 
> >> though. Finn, does it {look OK,work}?
> >
> > It looks fine. I can't test it right now, but I will do so when I get 
> > the opportunity.
> 
> Any news from the test front?

This is commit ba0f916ca7ac79356e2ed32a85c3aa8255b104e7, right?
If so, it tests OK here.

Finn

> 
> Gr{oetje,eeting}s,
> 
> 						Geert
