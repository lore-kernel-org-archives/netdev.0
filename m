From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] netdev: mdio-octeon: Fix section mismatch errors.
Date: Tue, 29 Jun 2010 00:00:22 -0700 (PDT)
Message-ID: <20100629.000022.241448825.davem@davemloft.net>
References: <1277406888-26309-1-git-send-email-ddaney@caviumnetworks.com>
	<1277406888-26309-3-git-send-email-ddaney@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org
To: ddaney@caviumnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47801
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752729Ab0F2HAI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 03:00:08 -0400
In-Reply-To: <1277406888-26309-3-git-send-email-ddaney@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Daney <ddaney@caviumnetworks.com>
Date: Thu, 24 Jun 2010 12:14:48 -0700

> We started getting:
> 
> WARNING: vmlinux.o(.data+0x20bd0): Section mismatch in reference from
> the variable octeon_mdiobus_driver to the function
> .init.text:octeon_mdiobus_probe()
> 
> This fixes it.
> 
> Signed-off-by: David Daney <ddaney@caviumnetworks.com>

Applied to net-next-2.6
