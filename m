From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/9] sfc: constify pci_error_handlers structures
Date: Mon, 16 Nov 2015 15:07:39 -0500 (EST)
Message-ID: <20151116.150739.1894829733349078407.davem@davemloft.net>
References: <1447495621-9161-1-git-send-email-Julia.Lawall@lip6.fr>
	<1447495621-9161-6-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, kernel-janitors@vger.kernel.org,
	sshah@solarflare.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40785 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750982AbbKPUHl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 15:07:41 -0500
In-Reply-To: <1447495621-9161-6-git-send-email-Julia.Lawall@lip6.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Sat, 14 Nov 2015 11:06:57 +0100

> This pci_error_handlers structure is never modified, like all the other
> pci_error_handlers structures, so declare it as const.
> 
> Done with the help of Coccinelle.
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied.
