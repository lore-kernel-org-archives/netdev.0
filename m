From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Misuse of LRO, how widespread
Date: Mon, 06 Dec 2010 22:35:12 +0000
Message-ID: <1291674912.5405.24.camel@bwh-desktop>
References: <20101206121829.5b8c852e@nehalam>
	 <1291667408.3443.10.camel@bwh-desktop>  <20101206143301.6b6dd17d@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Olof Johansson <olof@lixom.net>,
	Divy Le Ray <divy@chelsio.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:27410 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752508Ab0LFWfQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Dec 2010 17:35:16 -0500
In-Reply-To: <20101206143301.6b6dd17d@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-12-06 at 14:33 -0800, Stephen Hemminger wrote:
> How about this?
> 
> Subject: sfc: convert references to LRO to GRO
> 
> This driver now uses Generic Receive Offload, not the older LRO.
> Change references to LRO in names and comments.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Acked-by: Ben Hutchings <bhutchings@solarflare.com>

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

