From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 31/33] sfc: Use kzalloc() to ensure struct
 efx_spi_device is fully initialised
Date: Fri, 12 Dec 2008 22:09:02 -0800 (PST)
Message-ID: <20081212.220902.255999760.davem@davemloft.net>
References: <cover.1229085672.git.bhutchings@solarflare.com>
	<20081212124622.GK32518@solarflare.com>
	<20081212130029.GE10372@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57124
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755192AbYLMGJA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 01:09:00 -0500
In-Reply-To: <20081212130029.GE10372@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 12 Dec 2008 13:00:30 +0000

> Currently the mtd field is not initialised early enough.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
