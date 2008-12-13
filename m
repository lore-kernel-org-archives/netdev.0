From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 14/33] sfc: Remove MII extension cruft
Date: Fri, 12 Dec 2008 21:43:44 -0800 (PST)
Message-ID: <20081212.214344.06873682.davem@davemloft.net>
References: <cover.1229085672.git.bhutchings@solarflare.com>
	<20081212124622.GK32518@solarflare.com>
	<20081212125323.GN10372@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58428
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751363AbYLMFnn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 00:43:43 -0500
In-Reply-To: <20081212125323.GN10372@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 12 Dec 2008 12:53:24 +0000

> Replace efx_nic::link_options bitfield with link_speed (speed in
> Mbit/s) and link_fd (full duplex flag).
> 
> Remove broken auto-negotiation functions.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
