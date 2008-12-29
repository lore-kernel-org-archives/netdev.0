From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [GIT]: Networking
Date: Mon, 29 Dec 2008 09:17:28 -0800
Message-ID: <20081229091728.d869f1c1.akpm@linux-foundation.org>
References: <20081228.000118.121541932.davem@davemloft.net>
	<20081229102515.GA17171@rhlx01.hs-esslingen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: bunk@kernel.org, e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	auke-jan.h.kok@intel.com, linux-kernel@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>, torvalds@linux-foundation.org,
	David Miller <davem@davemloft.net>
To: Andreas Mohr <andi@lisas.de>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20081229102515.GA17171@rhlx01.hs-esslingen.de>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Mon, 29 Dec 2008 11:25:15 +0100 Andreas Mohr <andi@lisas.de> wrote:

> Hi,
> 
> > Adrian Bunk (1):
> > 
> >       The overdue eepro100 removal.
> 
> That would be a rather pronounced NAK then? (sorry ;)
> (reason: rendering my web surfing box useless due to networking loss,
> see thread "[RFC/PATCH] e100 driver didn't support any MII-less PHYs...")
> 
> AFAICS e100 is still "non-MII"-challenged (2.6.28 doesn't appear to have
> the necessary changes, and this pull doesn't seem to contain updates either),
> and a long chain of attempts to get this resolved hasn't worked yet.

I didn't know about this, and that patch has been around for a
loooooooong time.  Please make more noise about these things.

>
> Somehow I seem to hit some nice walls getting my stuff into kernel.
> - e100 MII

What's that?  Does it make your web surfing work again?

> - i810 AGP resume fix

Whats that?

> - acx100 (ok, that one is a bit mean to add to this list ;)

What's that?

Just resend everything, please, fulyl changelogged, with all necessary
cc's.

> - ...
> ALSA patches handled by Takashi OTOH were almost always a
> "bammm, in it is, there you are, HAND".

Fell free to cc me on these things - especially bugfixes.  I help
prevent things from getting lost.


------------------------------------------------------------------------------
