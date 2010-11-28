From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH] econet: Move to staging; remove from defconfig
Date: Sat, 27 Nov 2010 17:39:23 -0800
Message-ID: <20101128013923.GA9285@suse.de>
References: <1290897868.3292.59.camel@localhost>
	<20101128002135.GA4562@suse.de>
	<20101127.172644.226781076.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org, ben@decadent.org.uk,
	linux-arm-kernel@lists.infradead.org, debian-kernel@lists.debian.org
To: David Miller <davem@davemloft.net>
Return-path: <devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <20101127.172644.226781076.davem@davemloft.net>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/devel>,
	<mailto:devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/devel>
List-Post: <mailto:devel@linuxdriverproject.org>
List-Help: <mailto:devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/devel>,
	<mailto:devel-request@linuxdriverproject.org?subject=subscribe>
Sender: devel-bounces@linuxdriverproject.org
Errors-To: devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On Sat, Nov 27, 2010 at 05:26:44PM -0800, David Miller wrote:
> From: Greg KH <gregkh@suse.de>
> Date: Sat, 27 Nov 2010 16:21:35 -0800
> 
> > And I need an ack from the networking maintainer to be able to accept
> > this also.
> 
> I'm not applying this, nor do I want anyone else to.
> 
> If people think this protocol is not maintained adequately
> right now, wait until you push it into staging.
> 
> Furthermore, once Phil Blundell was made aware of security
> holes in econet he fixed them within a few days.  Which is
> much better than I can say for some of the other protocols
> and filesystems in the tree.
> 
> Moving this into staging, is therefore not appropriate.

Agreed.

Ben, why are you trying to remove these protocols that people use and
maintain?  This is the third one that has been shot down recently...
