From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 06/12] sfc: Remove EFX_WORKAROUND_9141 macro
Date: Sat, 28 Nov 2009 23:59:29 -0800 (PST)
Message-ID: <20091128.235929.102451435.davem@davemloft.net>
References: <1259422524.3709.7.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42931
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753810AbZK2H7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 02:59:24 -0500
In-Reply-To: <1259422524.3709.7.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Sat, 28 Nov 2009 15:35:24 +0000

> From: Matthew Slattery <mslattery@solarflare.com>
> 
> The "bug9141 workaround" of setting TX_FLUSH_MIN_LEN_EN should really
> be considered as a normal bit of configuration rather than a
> workaround.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
