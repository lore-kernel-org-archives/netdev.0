From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] mlx4_en fixes for 4.7-rc
Date: Wed, 22 Jun 2016 16:38:40 -0400 (EDT)
Message-ID: <20160622.163840.1975240645686212625.davem@davemloft.net>
References: <1466433309-16288-1-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52013 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752069AbcFVUio (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 16:38:44 -0400
In-Reply-To: <1466433309-16288-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>
Date: Mon, 20 Jun 2016 17:35:07 +0300

> This small patchset includes two small fixes for mlx4_en driver.
> 
> One allows a clean shutdown even when clients do not release their
> netdev reference.
> The other adds error return values to the VLAN VID add/kill functions.

Series applied.
