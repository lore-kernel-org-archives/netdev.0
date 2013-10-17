From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] net/mlx4: Mellanox driver update
 15-10-2013
Date: Thu, 17 Oct 2013 15:13:05 -0400 (EDT)
Message-ID: <20131017.151305.648362128512487002.davem@davemloft.net>
References: <1381848924-18992-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eyalpe@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46176 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759117Ab3JQTNK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 15:13:10 -0400
In-Reply-To: <1381848924-18992-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Tue, 15 Oct 2013 16:55:20 +0200

> This patchset contains small code cleaning patches, and a patch to make
> mlx4_core use module_request() in order to load the relevant link layer module
> (mlx4_en or mlx4_ib) according to the port type.

Series applied, thanks.
