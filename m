From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sfc: SFT9001: Fix condition for LNPGA power-off
Date: Sun, 11 Jan 2009 00:18:21 -0800 (PST)
Message-ID: <20090111.001821.67800032.davem@davemloft.net>
References: <1231628703.2671.3.camel@hashbaz.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55245
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750946AbZAKISU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 03:18:20 -0500
In-Reply-To: <1231628703.2671.3.camel@hashbaz.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Sat, 10 Jan 2009 23:05:03 +0000

> Only the SFX7101 requires software power control.  This was
> incorrectly being applied to the SFT9001 rev A as well.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied, thanks Ben.
