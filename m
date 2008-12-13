From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/33] sfc: Board support fixes
Date: Fri, 12 Dec 2008 21:29:56 -0800 (PST)
Message-ID: <20081212.212956.40506204.davem@davemloft.net>
References: <cover.1229085672.git.bhutchings@solarflare.com>
	<20081212124622.GK32518@solarflare.com>
	<20081212124824.GA10372@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58408
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751398AbYLMF3y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 00:29:54 -0500
In-Reply-To: <20081212124824.GA10372@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 12 Dec 2008 12:48:26 +0000

> Set dummy monitor method for unrecognised boards.
> 
> Clean up board resources if efx_pci_probe_main() fails after board has
> been initialised.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
