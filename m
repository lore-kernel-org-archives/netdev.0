From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] netdev: remove unused S2IO_NAPI
Date: Sun, 06 Jul 2008 20:57:55 -0700 (PDT)
Message-ID: <20080706.205755.184418749.davem@davemloft.net>
References: <20080705.212051.82650078.davem@davemloft.net>
	<20080706214109.GA13120@electric-eye.fr.zoreil.com>
	<487176F3.1030707@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52176
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753924AbYGGD5z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jul 2008 23:57:55 -0400
In-Reply-To: <487176F3.1030707@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jeff@garzik.org>
Date: Sun, 06 Jul 2008 21:52:51 -0400

> Francois Romieu wrote:
> > Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> > ---
> >  Documentation/networking/s2io.txt      |    7 ++-----
> >  arch/ia64/configs/sn2_defconfig        |    1 -
> >  arch/mips/configs/mtx1_defconfig       |    1 -
> >  arch/powerpc/configs/pseries_defconfig |    1 -
> >  arch/x86/configs/x86_64_defconfig      |    1 -
> >  drivers/net/Kconfig                    |   14 --------------
> >  6 files changed, 2 insertions(+), 23 deletions(-)
> 
> patches 1-3,
> 
> Acked-by: Jeff Garzik <jgarzik@redhat.com>

Applied to net-next-2.6, thanks everyone!
