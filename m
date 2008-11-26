From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Naming interrupt vectors/niu
Date: Tue, 25 Nov 2008 16:42:30 -0800 (PST)
Message-ID: <20081125.164230.33497190.davem@davemloft.net>
References: <18732.7560.67492.918339@robur.slu.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Robert.Olsson@data.slu.se
To: robert@robur.slu.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49168
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751255AbYKZAmb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 19:42:31 -0500
In-Reply-To: <18732.7560.67492.918339@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Olsson <robert@robur.slu.se>
Date: Tue, 25 Nov 2008 16:45:12 +0100

>  A patch to put names on the niu interrupt vectors according the syntax below. 
>  This is needed to assign correct affinity.
> 
>  > So on a multiqueue card with 2 RX queues and 2 TX queues we'd
>  > have names like:
>  > 
>  > 	eth0-rx-0
>  > 	eth0-rx-1
>  > 	eth0-tx-0
>  > 	eth0-tx-1
> 
> 
> Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>

Applied with some minor coding style fixups, thanks Robert.
