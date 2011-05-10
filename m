From: "Christian T. Steigies" <cts@debian.org>
Subject: Re: 8390 drivers (was: Re: Debian kernel 2.6.38-5)
Date: Tue, 10 May 2011 09:29:28 +0200
Message-ID: <20110510072928.GA32679@chumley.earth.sol>
References: <BANLkTimG+3jqLiLaA_NVEpGg3LFtvK4bQQ@mail.gmail.com>
 <20110509213213.GA28675@chumley.earth.sol>
 <BANLkTik27HjWOF0s5HRqgva5zYzQRis27Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Finn Thain <fthain@telegraphics.com.au>,
	Thorsten Glaser <tg@mirbsd.de>, linux-m68k@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-m68k-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <BANLkTik27HjWOF0s5HRqgva5zYzQRis27Q@mail.gmail.com>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 10, 2011 at 08:52:48AM +0200, Geert Uytterhoeven wrote:
> >
> > zorro8390.mod.c
> 
> That's a generated file, so you can ignore it.

ok

> Yeah, speed depends on CPU type and motherboard/CPU interface.

well, it was much faster for a while. Now, after downloading and during
installing packages (and switching to dependency based booting, etc), I get:

eth0: mismatched read page pointer:  1 vs ff.
and
eth0: mismatched read page pointer:  1 vs f0. (I think, maybe fe or  0)

A lot of them. So many that I can not stop the output or do anything on the
machine :-(
There is a different message as well, but it is not readable.

Christian
