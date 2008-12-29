From: Andreas Mohr <andi@lisas.de>
Subject: Re: [GIT]: Networking
Date: Mon, 29 Dec 2008 11:25:15 +0100
Message-ID: <20081229102515.GA17171@rhlx01.hs-esslingen.de>
References: <20081228.000118.121541932.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, bunk@kernel.org, linux-kernel@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	akpm@linux-foundation.org, torvalds@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20081228.000118.121541932.davem@davemloft.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hi,

> Adrian Bunk (1):
> 
>       The overdue eepro100 removal.

That would be a rather pronounced NAK then? (sorry ;)
(reason: rendering my web surfing box useless due to networking loss,
see thread "[RFC/PATCH] e100 driver didn't support any MII-less PHYs...")

AFAICS e100 is still "non-MII"-challenged (2.6.28 doesn't appear to have
the necessary changes, and this pull doesn't seem to contain updates either),
and a long chain of attempts to get this resolved hasn't worked yet.


Somehow I seem to hit some nice walls getting my stuff into kernel.
- e100 MII
- i810 AGP resume fix
- acx100 (ok, that one is a bit mean to add to this list ;)
- ...
ALSA patches handled by Takashi OTOH were almost always a
"bammm, in it is, there you are, HAND".

I can't seem to wash away my slightly CK'ish feeling ;)

Thanks,

Andreas Mohr

------------------------------------------------------------------------------
