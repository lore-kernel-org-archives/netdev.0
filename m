From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: use skb_postpush_rcsum instead of own
 implementations
Date: Fri, 19 Feb 2016 23:43:34 -0500 (EST)
Message-ID: <20160219.234334.1254668686162658568.davem@davemloft.net>
References: <bb805bd677f8ba6f5c40b485ed41009d3fef1f3d.1455924108.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, jesse@kernel.org, ast@kernel.org,
	netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42591 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423636AbcBTEng (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 23:43:36 -0500
In-Reply-To: <bb805bd677f8ba6f5c40b485ed41009d3fef1f3d.1455924108.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Sat, 20 Feb 2016 00:29:30 +0100

> Replace individual implementations with the recently introduced
> skb_postpush_rcsum() helper.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thanks Daniel.
