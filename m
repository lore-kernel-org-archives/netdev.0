From: David Miller <davem@davemloft.net>
Subject: Re: [git patches] net driver updates for .27
Date: Sat, 05 Jul 2008 21:20:51 -0700 (PDT)
Message-ID: <20080705.212051.82650078.davem@davemloft.net>
References: <20080704125446.GA30300@havoc.gtf.org>
	<20080705.211029.199316974.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36558
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750737AbYGFEUv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jul 2008 00:20:51 -0400
In-Reply-To: <20080705.211029.199316974.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Sat, 05 Jul 2008 21:10:29 -0700 (PDT)

> From: Jeff Garzik <jeff@garzik.org>
> Date: Fri, 4 Jul 2008 08:54:46 -0400
> 
> > Please pull from 'davem-next' branch of
> > master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git davem-next
> > 
> > to receive the following updates:
> 
> Pulled and pushed back out ot net-next-2.6, thanks!

BTW, it was super nice to finally see the non-NAPI config
options get obliterated.

For those playing at home, these are the similar turds still
remaining:

AMD8111E_NAPI
ADAPTEC_STARFIRE_NAPI
FORCEDETH_NAPI
VIA_RHINE_NAPI
E1000_NAPI
GFAR_NAPI
UGETH_NAPI
CHELSIO_T1_NAPI
IXGB_NAPI
S2IO_NAPI
TULIP_NAPI
