From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: gianfar - initialize per-queue statistics
Date: Tue, 30 Mar 2010 23:09:13 -0700 (PDT)
Message-ID: <20100330.230913.80853259.davem@davemloft.net>
References: <1269986062-1697-1-git-send-email-kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: avorontsov@ru.mvista.com, Sandeep.Kumar@freescale.com,
	galak@kernel.crashing.org, afleming@freescale.com,
	netdev@vger.kernel.org
To: kim.phillips@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56787
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932129Ab0CaGJM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 02:09:12 -0400
In-Reply-To: <1269986062-1697-1-git-send-email-kim.phillips@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kim Phillips <kim.phillips@freescale.com>
Date: Tue, 30 Mar 2010 16:54:21 -0500

> Interfaces come up claiming having already received 3.0 GiB.
> Use kzalloc to properly initialize per-queue data.
> 
> Signed-off-by: Kim Phillips <kim.phillips@freescale.com>

Applied.
