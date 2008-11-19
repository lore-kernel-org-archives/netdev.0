From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ixgbe: fix compilation with gcc-3.4
Date: Wed, 19 Nov 2008 14:17:13 -0800 (PST)
Message-ID: <20081119.141713.62157635.davem@davemloft.net>
References: <20081117100149.GA10586@x200.localdomain>
	<Pine.WNT.4.64.0811171125390.7996@ppwaskie-MOBL2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, netdev@vger.kernel.org
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36091
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750747AbYKSWRO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 17:17:14 -0500
In-Reply-To: <Pine.WNT.4.64.0811171125390.7996@ppwaskie-MOBL2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Date: Mon, 17 Nov 2008 11:26:46 -0800 (Pacific Standard Time)

> 
> On Mon, 17 Nov 2008, Alexey Dobriyan wrote:
> 
> >   CC [M]  drivers/net/ixgbe/ixgbe_main.o
> > drivers/net/ixgbe/ixgbe_main.c: In function `ixgbe_intr':
> > drivers/net/ixgbe/ixgbe_main.c:1290: sorry, unimplemented: inlining failed in call to 'ixgbe_irq_enable': function body not available
> > drivers/net/ixgbe/ixgbe_main.c:1312: sorry, unimplemented: called from here
> > make[4]: *** [drivers/net/ixgbe/ixgbe_main.o] Error 1
> > 
> > Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
 ...
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

Applied.
