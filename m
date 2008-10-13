From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] net/au1000_eth.c MDIO namespace fixes
Date: Sun, 12 Oct 2008 21:03:06 -0700 (PDT)
Message-ID: <20081012.210306.222286255.davem@davemloft.net>
References: <20081012124939.GI31153@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: buytenh@marvell.com, jgarzik@pobox.com, ralf@linux-mips.org,
	linux-mips@linux-mips.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: bunk@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46836
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750900AbYJMEDa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 00:03:30 -0400
In-Reply-To: <20081012124939.GI31153@cs181140183.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Adrian Bunk <bunk@kernel.org>
Date: Sun, 12 Oct 2008 15:49:39 +0300

> Commit 2e888103295f47b8fcbf7e9bb8c5da97dd2ecd76
> (phylib: add mdiobus_{read,write}) causes the
> following compile error:
 ...
> This patch prefixes the driver functions with au1000_ 
> 
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

Also applied, thanks a lot.
