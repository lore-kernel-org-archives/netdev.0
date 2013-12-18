From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] inet: make no_pmtu_disc per namespace and
 kill ipv4_config
Date: Wed, 18 Dec 2013 16:59:02 -0500 (EST)
Message-ID: <20131218.165902.1725263148949899416.davem@davemloft.net>
References: <20131214041329.GE7332@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57030 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754130Ab3LRV7E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 16:59:04 -0500
In-Reply-To: <20131214041329.GE7332@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Sat, 14 Dec 2013 05:13:38 +0100

> The other field in ipv4_config, log_martians, was converted to a
> per-interface setting, so we can just remove the whole structure.
> 
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied.
