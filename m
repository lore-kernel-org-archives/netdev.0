From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2] net: sh_eth: fix driver dependencies
Date: Tue, 2 Sep 2014 08:39:31 +0900
Message-ID: <20140901233931.GC15867@verge.net.au>
References: <1749721.1a6rN6K2Gg@amdc1032>
 <CAMuHMdWGdD+-o9Z8gPYwJWJmjhBqfw0HA4ve=RH+adLFJEZa8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	"David S. Miller" <davem@davemloft.net>,
	Magnus Damm <magnus.damm@gmail.com>,
	Kyungmin Park <kyungmin.park@samsung.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux-sh list <linux-sh@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-sh-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAMuHMdWGdD+-o9Z8gPYwJWJmjhBqfw0HA4ve=RH+adLFJEZa8Q@mail.gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 01, 2014 at 06:36:19PM +0200, Geert Uytterhoeven wrote:
> On Mon, Sep 1, 2014 at 4:25 PM, Bartlomiej Zolnierkiewicz
> <b.zolnierkie@samsung.com> wrote:
> > Renesas SuperH Ethernet support should be available only on
> > Renesas ARM SoCs and SuperH architecture.
> >
> > Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> > Acked-by: Kyungmin Park <kyungmin.park@samsung.com>
> > Cc: Simon Horman <horms@verge.net.au>
> > Cc: Magnus Damm <magnus.damm@gmail.com>
> > ---
> > v2:
> > - s/ARCH_SH/SUPERH/ (thanks to Sergei Shtylyov)
> 
> Acked-by: Geert Uytterhoeven <geert+renesas@glider.be>

Acked-by: Simon Horman <horms+renesas@verge.net.au>

