From: Manuel Lauss <mano@roarinelk.homelinux.net>
Subject: Re: smc91x: commit 51ac3beffd4afaea4350526cf01fe74aaff25eff breaks
	compilation
Date: Mon, 3 Nov 2008 09:26:35 +0100
Message-ID: <20081103082635.GF18445@roarinelk.homelinux.net>
References: <20081103071720.GB18153@roarinelk.homelinux.net> <20081103.000438.62068550.davem@davemloft.net> <20081103081724.GE18445@roarinelk.homelinux.net> <20081103.002021.124910044.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vapier@gentoo.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fnoeppeil48.netpark.at ([217.175.205.176]:47992 "EHLO
	roarinelk.homelinux.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754727AbYKCI0g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 03:26:36 -0500
Content-Disposition: inline
In-Reply-To: <20081103.002021.124910044.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 03, 2008 at 12:20:21AM -0800, David Miller wrote:
> From: Manuel Lauss <mano@roarinelk.homelinux.net>
> Date: Mon, 3 Nov 2008 09:17:24 +0100
> 
> > That throws another error:
> > 
> > /mnt/work/sh7760/kernel/linux-2.6.git/drivers/net/smc91x.c: In function 'smc_request_attrib':
> > /mnt/work/sh7760/kernel/linux-2.6.git/drivers/net/smc91x.c:2063: error: expected ',' or ';' before '__attribute__'
> > /mnt/work/sh7760/kernel/linux-2.6.git/drivers/net/smc91x.c: In function 'smc_release_attrib':
> > /mnt/work/sh7760/kernel/linux-2.6.git/drivers/net/smc91x.c:2078: error: expected ',' or ';' before '__attribute__'
> 
> Sorry, does this new version below work better?

Aye, much better.
 
Thanks,
	Manuel Lauss
