From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] be2net: use PCIe AER capability
Date: Wed, 05 Sep 2012 17:51:12 -0400 (EDT)
Message-ID: <20120905.175112.888883390468311562.davem@davemloft.net>
References: <2fad6337-6291-43f5-af76-e8ba8a9a5296@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45079 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759615Ab2IEVvN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2012 17:51:13 -0400
In-Reply-To: <2fad6337-6291-43f5-af76-e8ba8a9a5296@exht1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Wed, 5 Sep 2012 17:26:48 +0530

> This patch allows code to handle the PCIe AER capability.
> The PCI callbacks for error handling/reset/recovery already exist in be2net
> and have been tested with EEH/ppc.
> This patch has been tested using the aer-inject tool.
> 
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

Applied.
