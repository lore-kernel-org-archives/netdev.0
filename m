From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 10/17] sfc: Move SPI state to struct
 falcon_nic_data
Date: Fri, 03 Dec 2010 09:09:29 -0800 (PST)
Message-ID: <20101203.090929.115935147.davem@davemloft.net>
References: <1291333490.3259.23.camel@bwh-desktop>
	<1291333649.3259.33.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42687
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752908Ab0LCRJD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Dec 2010 12:09:03 -0500
In-Reply-To: <1291333649.3259.33.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 02 Dec 2010 23:47:29 +0000

> We only have direct access to SPI on Falcon, so move all this state
> out of struct efx_nic.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
