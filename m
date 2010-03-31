From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: gianfar - align BD ring size console messages
Date: Tue, 30 Mar 2010 23:09:19 -0700 (PDT)
Message-ID: <20100330.230919.75786481.davem@davemloft.net>
References: <1269986062-1697-1-git-send-email-kim.phillips@freescale.com>
	<1269986062-1697-2-git-send-email-kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: avorontsov@ru.mvista.com, Sandeep.Kumar@freescale.com,
	galak@kernel.crashing.org, afleming@freescale.com,
	netdev@vger.kernel.org
To: kim.phillips@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56793
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932609Ab0CaGJS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 02:09:18 -0400
In-Reply-To: <1269986062-1697-2-git-send-email-kim.phillips@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kim Phillips <kim.phillips@freescale.com>
Date: Tue, 30 Mar 2010 16:54:22 -0500

> fix this:
> 
> eth2: :RX BD ring size for Q[0]: 256
> eth2:TX BD ring size for Q[0]: 256
> 
> to look like:
> 
> eth2: RX BD ring size for Q[0]: 256
> eth2: TX BD ring size for Q[0]: 256
> 
> Signed-off-by: Kim Phillips <kim.phillips@freescale.com>

Applied.
