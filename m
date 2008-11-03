From: David Miller <davem@davemloft.net>
Subject: Re: smc91x: commit 51ac3beffd4afaea4350526cf01fe74aaff25eff breaks
 compilation
Date: Mon, 03 Nov 2008 00:28:22 -0800 (PST)
Message-ID: <20081103.002822.81557226.davem@davemloft.net>
References: <20081103081724.GE18445@roarinelk.homelinux.net>
	<20081103.002021.124910044.davem@davemloft.net>
	<20081103082635.GF18445@roarinelk.homelinux.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vapier@gentoo.org, netdev@vger.kernel.org
To: mano@roarinelk.homelinux.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59709
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754594AbYKCI2r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 03:28:47 -0500
In-Reply-To: <20081103082635.GF18445@roarinelk.homelinux.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manuel Lauss <mano@roarinelk.homelinux.net>
Date: Mon, 3 Nov 2008 09:26:35 +0100

> On Mon, Nov 03, 2008 at 12:20:21AM -0800, David Miller wrote:
> > From: Manuel Lauss <mano@roarinelk.homelinux.net>
> > Date: Mon, 3 Nov 2008 09:17:24 +0100
> > 
> > > That throws another error:
> > > 
> > > /mnt/work/sh7760/kernel/linux-2.6.git/drivers/net/smc91x.c: In function 'smc_request_attrib':
> > > /mnt/work/sh7760/kernel/linux-2.6.git/drivers/net/smc91x.c:2063: error: expected ',' or ';' before '__attribute__'
> > > /mnt/work/sh7760/kernel/linux-2.6.git/drivers/net/smc91x.c: In function 'smc_release_attrib':
> > > /mnt/work/sh7760/kernel/linux-2.6.git/drivers/net/smc91x.c:2078: error: expected ',' or ';' before '__attribute__'
> > 
> > Sorry, does this new version below work better?
> 
> Aye, much better.

Thanks for testing.
