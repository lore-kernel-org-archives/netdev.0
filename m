From: Lennert Buytenhek <kernel@wantstofly.org>
Subject: Re: [PATCH] ep93xx-eth: convert to phylib
Date: Mon, 6 Jun 2011 19:34:38 +0200
Message-ID: <20110606173438.GC11275@wantstofly.org>
References: <201106051957.36492.florian@openwrt.org>
	<201106052029.24742.f.fainelli@gmail.com>
	<20110605.140657.1039864716002412071.davem@davemloft.net>
	<201106060715.52332.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mika.westerberg@iki.fi, hvr@gnu.org,
	hsweeten@visionengravers.com, ryan@bluewatersys.com,
	David Miller <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org
To: Florian Fainelli <florian@openwrt.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <201106060715.52332.florian@openwrt.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 06, 2011 at 07:15:52AM +0200, Florian Fainelli wrote:

> > Instead there are several different people submitting changes to
> > this one driver and I haven't got a clue who is authoritative and
> > who is not.
> > 
> > So 9 times out of ten I'm not going to merge anything submitted
> > in this way unless I start to see lots of ACKs from other developers.
> > 
> > When it gets to the point where multiple people are touching the
> > driver in all sorts of ways, there needs to be someone to do all of
> > the merging and making sure the patches get applied in the right order
> > and handling merge conflicts handled properly.  Then they submit them
> > formally here as a sane single set of patches to the list.
> > 
> > So who is going to step up and be the ep93xx-eth maintainer?  Lennert
> > is listed in MAINTAINERS, but I see little to no activity from him.
> 
> Lennert, do you still have time, hardware and will to maintain that driver?

I still have hardware, but I have been pretty short on time lately.
I'd be happy to hand over maintainership of this driver.
