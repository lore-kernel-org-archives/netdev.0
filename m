From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] gianfar: Fix build with CONFIG_PM enabled
Date: Sat, 21 Mar 2009 13:28:11 -0700 (PDT)
Message-ID: <20090321.132811.142453736.davem@davemloft.net>
References: <20090319151217.GA11465@oksana.dev.rtsoft.ru>
	<DA082A7B-8C8A-47A9-9B50-143AF6A27F18@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: avorontsov@ru.mvista.com, afleming@freescale.com,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: galak@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43161
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752605AbZCUU2X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 16:28:23 -0400
In-Reply-To: <DA082A7B-8C8A-47A9-9B50-143AF6A27F18@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Gala <galak@kernel.crashing.org>
Date: Thu, 19 Mar 2009 10:16:26 -0500

> 
> On Mar 19, 2009, at 10:12 AM, Anton Vorontsov wrote:
> 
> > commit 4826857f1bf07f9c0f1495e9b05d125552c88a85 ("gianfar: pass the
> > proper dev to DMA ops") introduced this build breakage:
...
> > Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
> 
> Acked-by: Kumar Gala <galak@kernel.crashing.org>

Applied, thanks.
