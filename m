From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/9] net: cavium: liquidio: constify pci_error_handlers
 structures
Date: Mon, 16 Nov 2015 15:07:45 -0500 (EST)
Message-ID: <20151116.150745.188460724093737913.davem@davemloft.net>
References: <1447495621-9161-1-git-send-email-Julia.Lawall@lip6.fr>
	<1447495621-9161-2-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: derek.chickles@caviumnetworks.com, kernel-janitors@vger.kernel.org,
	satananda.burla@caviumnetworks.com,
	felix.manlunas@caviumnetworks.com,
	raghu.vatsavayi@caviumnetworks.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40790 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752303AbbKPUHr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 15:07:47 -0500
In-Reply-To: <1447495621-9161-2-git-send-email-Julia.Lawall@lip6.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Sat, 14 Nov 2015 11:06:53 +0100

> This pci_error_handlers structure is never modified, like all the other
> pci_error_handlers structures, so declare it as const.
> 
> Done with the help of Coccinelle.
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied.
