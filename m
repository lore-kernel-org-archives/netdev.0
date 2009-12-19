From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TI DaVinci EMAC: Fix MDIO bus frequency configuration
Date: Fri, 18 Dec 2009 20:22:06 -0800 (PST)
Message-ID: <20091218.202206.179936658.davem@davemloft.net>
References: <1260955739-30348-1-git-send-email-nageswari@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, anantgole@ti.com,
	davinci-linux-open-source@linux.davincidsp.com
To: nageswari@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52522
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755349AbZLSEWF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 23:22:05 -0500
In-Reply-To: <1260955739-30348-1-git-send-email-nageswari@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nageswari Srinivasan <nageswari@ti.com>
Date: Wed, 16 Dec 2009 14:58:59 +0530

> There was a typo in "if condition" checking for validity of MDIO
> bus frequency passed as part of platform data. Bitwise AND was
> being used instead of a Logical AND.
> 
> Tested on: DM6467 EVM
> 
> Signed-off-by: Nageswari Srinivasan <nageswari@ti.com>
> Acked-by: Anant Gole <anantgole@ti.com>

Patch applied, thanks.
