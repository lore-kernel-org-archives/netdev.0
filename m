From: David Miller <davem@davemloft.net>
Subject: Re: [v10, 0/6] Freescale DPAA FMan
Date: Sun, 27 Dec 2015 21:14:03 -0500 (EST)
Message-ID: <20151227.211403.242539822762320022.davem@davemloft.net>
References: <1450657290-6644-1-git-send-email-igal.liberman@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-kernel@vger.kernel.org, scottwood@freescale.com,
	madalin.bucur@freescale.com, pebolle@tiscali.nl,
	joakim.tjernlund@transmode.se, ppc@mindchasers.com,
	stephen@networkplumber.org, afleming@gmail.com, knneth@gmail.com
To: igal.liberman@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44570 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750894AbbL1COI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Dec 2015 21:14:08 -0500
In-Reply-To: <1450657290-6644-1-git-send-email-igal.liberman@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <igal.liberman@freescale.com>
Date: Mon, 21 Dec 2015 02:21:24 +0200

> The Freescale Data Path Acceleration Architecture (DPAA) is a set
> of hardware components on specific QorIQ multicore processors.
> This architecture provides the infrastructure to support
> simplified sharing of networking interfaces and accelerators
> by multiple CPU cores and the accelerators.
> 
> One of the DPAA accelerators is the Frame Manager (FMan)
> which contains a series of hardware blocks: ports, Ethernet MACs,
> a multi user RAM (MURAM) and Storage Profile (SP).
> 
> This patch set introduce the FMan drivers.
> Each driver configures and initializes the corresponding
> FMan hardware module (described above).
> The MAC driver offers support for three different
> types of MACs (eTSEC, TGEC, MEMAC).

Series applied, thanks.
