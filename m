From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] export genphy_restart_aneg
Date: Mon, 13 Oct 2008 18:48:17 -0700 (PDT)
Message-ID: <20081013.184817.87272235.davem@davemloft.net>
References: <20081013171900.GK29938@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: buytenh@marvell.com, afleming@freescale.com, jgarzik@pobox.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: bunk@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56531
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754851AbYJNBsl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 21:48:41 -0400
In-Reply-To: <20081013171900.GK29938@cs181140183.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Adrian Bunk <bunk@kernel.org>
Date: Mon, 13 Oct 2008 20:19:00 +0300

> This patch fixes the following build error caused by
> commit ed94493fb38a665cebcf750dfabe8a6dd13e136f
> (mv643xx_eth: convert to phylib):

Applied, th anks Adrian.
