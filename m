From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: Re: [PATCH -mm] ssb: open-code dma_alloc_coherent
Date: Tue, 16 Feb 2010 11:05:03 +0900
Message-ID: <20100216110422O.fujita.tomonori@lab.ntt.co.jp>
References: <4B78EE6A.3010207@lwfinger.net>
	<20100215162426V.fujita.tomonori@lab.ntt.co.jp>
	<4B79E251.3020005@lwfinger.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fujita.tomonori@lab.ntt.co.jp, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, mb@bu3sch.de, davem@davemloft.net,
	stefano.brivio@polimi.it, akpm@linux-foundation.org
To: Larry.Finger@lwfinger.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sh.osrg.net ([192.16.179.4]:36285 "EHLO sh.osrg.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932362Ab0BPCFw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Feb 2010 21:05:52 -0500
In-Reply-To: <4B79E251.3020005@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 15 Feb 2010 18:09:53 -0600
Larry Finger <Larry.Finger@lwfinger.net> wrote:

> On 02/15/2010 01:25 AM, FUJITA Tomonori wrote:
> > 2.6.33-rc8:
> > 
> > git://git.kernel.org/pub/scm/linux/kernel/git/tomo/linux-2.6-misc.git pending
> > 
> > The ssb patch depends on the latest eight patches in the tree:
> > 
> > http://marc.info/?l=linux-kernel&m=126596737604808&w=2
> 
> The DMA changes work on i386 architecture with wireless devices in Cardbus (PCI)
> format. Both b43legacy and b43 were tested.

Great, thanks a lot!

I've posted the second version:

http://marc.info/?l=linux-kernel&m=126624677226865&w=2

It's also available via the git tree:

git://git.kernel.org/pub/scm/linux/kernel/git/tomo/linux-2.6-misc.git pending

Can I get your ack on b43 stuff?


Thanks,
