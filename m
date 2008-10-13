From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] net/tc35815.c: fix compilation
Date: Sun, 12 Oct 2008 21:02:47 -0700 (PDT)
Message-ID: <20081012.210247.06669920.davem@davemloft.net>
References: <20081012124934.GH31153@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: buytenh@marvell.com, jgarzik@pobox.com, ralf@linux-mips.org,
	linux-mips@linux-mips.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: bunk@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46828
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750858AbYJMEDL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 00:03:11 -0400
In-Reply-To: <20081012124934.GH31153@cs181140183.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Adrian Bunk <bunk@kernel.org>
Date: Sun, 12 Oct 2008 15:49:34 +0300

> Fix an obvious typo introduced by
> commit 298cf9beb9679522de995e249eccbd82f7c51999
> (phylib: move to dynamic allocation of struct mii_bus).
...
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

Applied, thanks Adrian.
