From: Kyle McMartin <kyle@parisc-linux.org>
Subject: Re: [parisc-linux] [git patches] tulip fixes from parisc-linux
Date: Sun, 30 Jul 2006 12:56:07 -0400
Message-ID: <20060730165607.GB4835@athena.road.mcmartin.ca>
References: <20060729225459.GA4835@athena.road.mcmartin.ca> <20060730004339.GC11975@colo.lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Valerie Henson <val_henson@linux.intel.com>,
	netdev@vger.kernel.org, parisc-linux@lists.parisc-linux.org,
	akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stout.engsoc.carleton.ca ([134.117.69.22]:61579 "EHLO
	stout.engsoc.carleton.ca") by vger.kernel.org with ESMTP
	id S1751188AbWG3Q4l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Jul 2006 12:56:41 -0400
To: Grant Grundler <grundler@parisc-linux.org>
Content-Disposition: inline
In-Reply-To: <20060730004339.GC11975@colo.lackof.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 29, 2006 at 06:43:39PM -0600, Grant Grundler wrote:
> I just wanted to warn that some of the changes are already in akpm
> 's tree (-mm).
> Becuase off hand I've forgotten which ones, would it be better to
> diff against -mm instead?

tulip-fix-shutdown-dma-irq-race.patch
  tulip: fix shutdown DMA/irq race

tulip-fix-for-64-bit-mips.patch
  tulip: fix for 64-bit mips

tulip-natsemi-dp83840a-phy-fix.patch
  tulip: NatSemi DP83840A PHY fix

Are the tulip patches in -mm, found here:
http://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.18-rc2/2.6.18-rc2-mm1/broken-out/tulip-fix-for-64-bit-mips.patch
http://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.18-rc2/2.6.18-rc2-mm1/broken-out/tulip-fix-shutdown-dma-irq-race.patch
http://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.18-rc2/2.6.18-rc2-mm1/broken-out/tulip-natsemi-dp83840a-phy-fix.patch

[akpm: I added you to the CC list, if Val acks the patches can
you see that they make their way into -mm?
git.kernel.org/pub/scm/linux/kernel/git/kyle/tulip-2.6.git#master]

Cheers,
	Kyle M.

