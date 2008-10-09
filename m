From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/8 2.6.28] cxgb3 - More flexible support for PHY
 interrupts.
Date: Wed, 08 Oct 2008 17:42:30 -0700 (PDT)
Message-ID: <20081008.174230.11505932.davem@davemloft.net>
References: <20081009003418.13412.75569.stgit@speedy5>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59324
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757850AbYJIAmy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 20:42:54 -0400
In-Reply-To: <20081009003418.13412.75569.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>
Date: Wed, 08 Oct 2008 17:34:19 -0700

> Do not require PHY interrupts to be connected to GPIs in ascending order.
> Base interrupt availability both on PHYs supporting them and on GPIs being
> hooked up.  Allows boards to specify interrupt GPIs though the PHYs don't
> use them.
> Remove spurious PHY interrupts due to clearing T3DBG interrupts before
> setting their polarity.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>

Applied.
