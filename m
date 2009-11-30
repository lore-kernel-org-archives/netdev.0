From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 03/12] sfc: Remove static PHY data and enumerations
Date: Sun, 29 Nov 2009 17:24:24 -0800 (PST)
Message-ID: <20091129.172424.165435313.davem@davemloft.net>
References: <1259543335.3709.86.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46039
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752845AbZK3BYS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 20:24:18 -0500
In-Reply-To: <1259543335.3709.86.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 30 Nov 2009 01:08:55 +0000

> New NICs have firmware managing the PHY, and we will discover the PHY
> capabilities at run-time.  Replace the static data with probe() and
> test_name() operations.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
