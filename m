From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] netdev/phy: Implement ieee802.3 clause 45 in
 mdio-octeon.c
Date: Sun, 07 Apr 2013 17:12:47 -0400 (EDT)
Message-ID: <20130407.171247.907674638416538070.davem@davemloft.net>
References: <1365017132-6035-1-git-send-email-ddaney.cavm@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	david.daney@cavium.com
To: ddaney.cavm@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58530 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762175Ab3DGVMt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Apr 2013 17:12:49 -0400
In-Reply-To: <1365017132-6035-1-git-send-email-ddaney.cavm@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Daney <ddaney.cavm@gmail.com>
Date: Wed,  3 Apr 2013 12:25:32 -0700

> From: David Daney <david.daney@cavium.com>
> 
> The Octeon SMI/MDIO interfaces can do clause 45 communications, so
> implement this in the driver.
> 
> Also fix some comment formatting to make it consistent and to comply
> with the netdev style.
> 
> Signed-off-by: David Daney <david.daney@cavium.com>

Applied to net-next.
