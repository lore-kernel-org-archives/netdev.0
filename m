From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 3/3] sfc: Change falcon_probe_board() to fail
 for unsupported boards
Date: Wed, 28 Apr 2010 12:18:46 -0700 (PDT)
Message-ID: <20100428.121846.104041325.davem@davemloft.net>
References: <1272481235.2549.14.camel@achroite.uk.solarflarecom.com>
	<1272481310.2549.16.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52629
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756666Ab0D1TSl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 15:18:41 -0400
In-Reply-To: <1272481310.2549.16.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 28 Apr 2010 20:01:50 +0100

> The driver needs specific PHY and board support code for each SFC4000
> board; there is no point trying to continue if it is missing.
> Currently unsupported boards can trigger an 'oops'.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> Cc: stable@kernel.org

Applied.
