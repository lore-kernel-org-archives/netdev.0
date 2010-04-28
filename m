From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 16/17] sfc: Test only the first pair of TX queues
Date: Wed, 28 Apr 2010 12:46:45 -0700 (PDT)
Message-ID: <20100428.124645.35018005.davem@davemloft.net>
References: <1272482722.2549.17.camel@achroite.uk.solarflarecom.com>
	<1272483030.2549.32.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49153
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932110Ab0D1Tqj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 15:46:39 -0400
In-Reply-To: <1272483030.2549.32.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 28 Apr 2010 20:30:30 +0100

> This makes no immediate difference, but we definitely do not want
> to test all TX queues once we allocate a pair of TX queues to each
> channel.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
