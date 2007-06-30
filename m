From: Christoph Hellwig <hch@infradead.org>
Subject: Re: e1000: backport ich9 support from 7.5.5 ?
Date: Sat, 30 Jun 2007 09:26:43 +0100
Message-ID: <20070630082643.GB20140@infradead.org>
References: <1183138159.17243.16.camel@blaa> <20070629175006.GB3917@falooley.org> <468571C6.3090305@garzik.org> <46857C08.4030303@intel.com> <20070629150350.414553d4.akpm@linux-foundation.org> <4685838D.9080108@garzik.org> <c0a09e5c0706291657kd5e4baawb113a17ca5ab2191@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	Jason Lunz <lunz@reflexsecurity.com>,
	Mark McLoughlin <markmc@redhat.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Andrew Grover <andy.grover@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:48801 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753239AbXF3I0t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jun 2007 04:26:49 -0400
Content-Disposition: inline
In-Reply-To: <c0a09e5c0706291657kd5e4baawb113a17ca5ab2191@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 29, 2007 at 04:57:46PM -0700, Andrew Grover wrote:
> When I was at Intel, I heard a lot of "the linux community won't let
> us split the driver". "Oh well, guess we gotta keep lugging around all
> the old crap." So it was a (perhaps misunderstood) desire to make you
> guys happy that led to e1000 turning into a monster.

Where exactly is that crap coming from?  We've always told people to
split drivers if things go to divergent and there's some interesting
examples where the vendors has a monster driver and mainline has two
nicely split ones (sk98lin vs skge and sky2 for example).

