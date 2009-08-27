From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/7] sfc: Improve reliability of RX queue flushing
Date: Wed, 26 Aug 2009 18:04:25 -0700 (PDT)
Message-ID: <20090826.180425.143307681.davem@davemloft.net>
References: <1251310693.27345.19.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53170
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754488AbZH0BEL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 21:04:11 -0400
In-Reply-To: <1251310693.27345.19.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 26 Aug 2009 19:18:13 +0100

> Reconfiguring the port requires us to flush all DMA queues.  In
> repeated testing we have found that RX flushes would sometimes fail
> because the RX DMA engine was not properly isolated from the MACs.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
