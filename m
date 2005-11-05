From: Christoph Hellwig <hch@infradead.org>
Subject: Re: ancient ieee80211/ipw2200 drivers in recent kernel (2.6.14)
Date: Sat, 5 Nov 2005 00:21:00 +0000
Message-ID: <20051105002100.GA24128@infradead.org>
References: <873bmg9sym.fsf@vertex.dottedmag.net> <20051102020903.GG29803@verge.net.au> <871x1zk0a6.fsf@vertex.dottedmag.net> <20051102162620.GA32696@infradead.org> <20051104032918.GE4708@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <bounce-debian-kernel=glddk-debian-kernel=m.gmane.org@lists.debian.org>
To: Mikhail Gusarov <dottedmag@dottedmag.net>,
	debian-kernel@lists.debian.org, NetDev <netdev@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20051104032918.GE4708@verge.net.au>
Resent-Message-ID: <HkZK7C.A.JuC.L6_aDB@murphy>
List-Post: <mailto:debian-kernel@lists.debian.org>
List-Help: <mailto:debian-kernel-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-kernel-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-kernel-request@lists.debian.org?subject=unsubscribe>
List-Id: netdev.vger.kernel.org

On Fri, Nov 04, 2005 at 12:29:20PM +0900, Horms wrote:
> do I take that comment to mean that upstream can't update the
> drivers but Debian can? And if so, do you recommend updating 
> Debian's kernel packages, or putting the updates elsewhere?

Well, we could upstream, but so far no one is annoyed enough to
overrid the driver maintainer.  I'd suggest merging a more recent
driver into the debian kernel package.
