From: Horms <horms@debian.org>
Subject: Re: ancient ieee80211/ipw2200 drivers in recent kernel (2.6.14)
Date: Fri, 4 Nov 2005 12:29:20 +0900
Message-ID: <20051104032918.GE4708@verge.net.au>
References: <873bmg9sym.fsf@vertex.dottedmag.net> <20051102020903.GG29803@verge.net.au> <871x1zk0a6.fsf@vertex.dottedmag.net> <20051102162620.GA32696@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mikhail Gusarov <dottedmag@dottedmag.net>,
	debian-kernel@lists.debian.org, NetDev <netdev@vger.kernel.org>
Return-path: <bounce-debian-kernel=glddk-debian-kernel=m.gmane.org@lists.debian.org>
To: Christoph Hellwig <hch@infradead.org>
Content-Disposition: inline
In-Reply-To: <20051102162620.GA32696@infradead.org>
Resent-Message-ID: <goGrJC.A.zGG.5NuaDB@murphy>
List-Post: <mailto:debian-kernel@lists.debian.org>
List-Help: <mailto:debian-kernel-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-kernel-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-kernel-request@lists.debian.org?subject=unsubscribe>
List-Id: netdev.vger.kernel.org

On Wed, Nov 02, 2005 at 04:26:21PM +0000, Christoph Hellwig wrote:
> On Wed, Nov 02, 2005 at 12:54:09PM +0600, Mikhail Gusarov wrote:
> > So, having in mind the two levels of 'stablenesss': kernel
> > 'stableness' and modules 'stableness' :) we should find the way to
> > exclude discussed modules from the build, because in-kernel versions
> > will always be, erm..., slightly (1.0.0 is mentioned only as 'stone
> > age' in the mailing list of ipw2200 developers) outdated due to fact
> > integration and testing gets some time in upstream kernels. I propose
> > just to disable compilation of this drivers: everyone will be able to
> > compile the recent version using ipw2200-source we provide.
> 
> The kernel drivers aren't stable but obsolete.  Because of that ever
> distribution that supports it's users must patch in a more recent one,
> which is what we should do for debian aswell.
> 
> It's a pity the braindead Intel policies don't allow us to have an uptodate
> driver in mainline.

Christoph, 

do I take that comment to mean that upstream can't update the
drivers but Debian can? And if so, do you recommend updating 
Debian's kernel packages, or putting the updates elsewhere?

-- 
Horms
