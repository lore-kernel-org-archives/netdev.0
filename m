From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] can: omit received RTR frames for single ID
 filter lists
Date: Thu, 04 Dec 2008 15:01:34 -0800 (PST)
Message-ID: <20081204.150134.49365923.davem@davemloft.net>
References: <20081128153317.GA3726@e-circ.dyndns.org>
	<49381618.8030109@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greg@kroah.com, kurt.van.dijck@eia.be, netdev@vger.kernel.org,
	stable@kernel.org
To: oliver@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50652
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754035AbYLDXBe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 18:01:34 -0500
In-Reply-To: <49381618.8030109@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <oliver@hartkopp.net>
Date: Thu, 04 Dec 2008 18:40:40 +0100

> can: omit received RTR frames for single ID filter lists
> 
> Since commit d253eee20195b25e298bf162a6e72f14bf4803e5 the single CAN
> identifier filter lists handle only non-RTR CAN frames.
> 
> So we need to omit the check of these filter lists when receiving RTR CAN frames.
> 
> Signed-Off-by: Oliver Hartkopp <oliver@hartkopp.net>

Applied to net-2.6, thanks.

Please stop capitalizing the "Off"  in Signed-off-by, I keep
correcting that for you :-)

Thanks again.
