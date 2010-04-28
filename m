From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 1/3] sfc: Wait at most 10ms for the MC to
 finish reading out MAC statistics
Date: Wed, 28 Apr 2010 12:18:36 -0700 (PDT)
Message-ID: <20100428.121836.226790804.davem@davemloft.net>
References: <1272481235.2549.14.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52621
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755151Ab0D1TSc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 15:18:32 -0400
In-Reply-To: <1272481235.2549.14.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 28 Apr 2010 20:00:35 +0100

> The original code would wait indefinitely if MAC stats DMA failed.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> Cc: stable@kernel.org

Applied.
