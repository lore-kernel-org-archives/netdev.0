From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next] ipv6: allow routes to be configured with
 expire values
Date: Mon, 14 Dec 2015 14:36:45 -0500 (EST)
Message-ID: <20151214.143645.1177969141058180151.davem@davemloft.net>
References: <20151211.202157.2045048466167764855.davem@davemloft.net>
	<CADvbK_fxww6-EfDgdo-4e=UscsB_pvJO4z1NAPiFyujiA5xr0Q@mail.gmail.com>
	<566EF98B.8060704@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lucien.xin@gmail.com, netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59152 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752041AbbLNTgr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 14:36:47 -0500
In-Reply-To: <566EF98B.8060704@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Mon, 14 Dec 2015 18:16:59 +0100

> We can easily switch to new attributes. Should we introduce a new
> interface for this?

Yes.
