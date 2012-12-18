From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: validate addr_len on bind
Date: Mon, 17 Dec 2012 20:52:02 -0800 (PST)
Message-ID: <20121217.205202.386470556745785099.davem@davemloft.net>
References: <20121216014219.GB1528@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55056 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753862Ab2LREwC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2012 23:52:02 -0500
In-Reply-To: <20121216014219.GB1528@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Sun, 16 Dec 2012 02:42:19 +0100

> Otherwise an out of bounds read could happen.
> 
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied.
