From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: fix validation of D-SACK
Date: Tue, 20 Sep 2011 14:50:31 -0400 (EDT)
Message-ID: <20110920.145031.204355907434723091.davem@davemloft.net>
References: <4E76A36B.4060109@intel.com>
	<20110918.223744.2195272571175354579.davem@davemloft.net>
	<4E777BEC.7050600@computer.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zheng.z.yan@intel.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: jan.ceuleers@computer.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60684 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752399Ab1ITSuk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2011 14:50:40 -0400
In-Reply-To: <4E777BEC.7050600@computer.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Ceuleers <jan.ceuleers@computer.org>
Date: Mon, 19 Sep 2011 19:29:16 +0200

> Have you also queued it up for stable as per Eric's remark that this
> was introduced in 2.6.24?

Yes, I have.
