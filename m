From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fsl_pq_mdio: Clean up tbi address configuration
Date: Wed, 07 Dec 2011 13:55:31 -0500 (EST)
Message-ID: <20111207.135531.374464329249721077.davem@davemloft.net>
References: <436A94C3-8F5B-4A8F-A46B-B66B503B98A0@kernel.crashing.org>
	<20111206.004121.1820319056329214972.davem@davemloft.net>
	<3FAC1EB0-2606-40BF-9BDF-8D2BCEB003E9@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: afleming@freescale.com, netdev@vger.kernel.org
To: galak@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46644 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757925Ab1LGSzh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2011 13:55:37 -0500
In-Reply-To: <3FAC1EB0-2606-40BF-9BDF-8D2BCEB003E9@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Gala <galak@kernel.crashing.org>
Date: Tue, 6 Dec 2011 23:35:31 -0600

> We need this patch in 3.2 regardless of DT.  Currently we get the
> oops on 3.2 on ALL systems.  Andy should be working up a device tree
> patch to fix the subset of .dts that are missing the tbi property.

Ok, applied to 'net'.
