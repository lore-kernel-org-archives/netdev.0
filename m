From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6 V2] mlx4_en: Data path optimizations and bug fix
Date: Wed, 19 Oct 2011 03:47:37 -0400 (EDT)
Message-ID: <20111019.034737.335798410486856821.davem@davemloft.net>
References: <4E9D67FC.7000902@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52285 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753194Ab1JSHro (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 03:47:44 -0400
In-Reply-To: <4E9D67FC.7000902@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Tue, 18 Oct 2011 13:50:20 +0200

> This is V2 of the patches sent yesterday.
> The differences comparing to V1 are:
> 1. Remove patch 3/7 : "Incoming traffic alignment optimizations" following Eric's comments for a rework.
> 2. Using static seed value for Toeplitz function, rather then randomizing the value each time

Applied, thanks.
