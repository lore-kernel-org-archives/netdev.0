From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: large packet loss take2 2.6.31.x
Date: Wed, 25 Nov 2009 20:11:05 +0100
Message-ID: <20091125191105.GA3167@ami.dom.local>
References: <81bfc67a0911232217n41b9ac02w3b7770b789e5d209@mail.gmail.com>
	<20091124111946.GA7883@ff.dom.local>
	<81bfc67a0911250606k1ec76354n217da9ca20b3517c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Frans Pop <elendil@planet.nl>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Caleb Cushing <xenoterracide@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <81bfc67a0911250606k1ec76354n217da9ca20b3517c@mail.gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, Nov 25, 2009 at 09:06:30AM -0500, Caleb Cushing wrote:
> > Anyway, since there are problems with
> > getting stats from the router we still can't compare them, or check
> > for the dropped stats. (Btw, could you check for /proc/net/softnet_stat
> > yet?)
> 
> router? good kernel? bad kernel?

router.

> 
> > So, it might be the kernel problem you reported, but there is not
> > enough data to prove it. Then my proposal is to try to repeat this
> > problem in more "testing friendly" conditions - preferably against
> > some other, more up-to-date linux box, if possible?
> 
> yeah 2.6.31.6 works on my laptop fine I'll just have to see about
> getting a direct connection to it. probably do that after I bring the
> other NIC back from home, on thanksgiving.

This other NIC is a really good idea, so let's wait and see.

Happy Thanksgiving!
Jarek P.

------------------------------------------------------------------------------
Let Crystal Reports handle the reporting - Free Crystal Reports 2008 30-Day 
trial. Simplify your report design, integration and deployment - and focus on 
what you do best, core application coding. Discover what's new with
Crystal Reports now.  http://p.sf.net/sfu/bobj-july
