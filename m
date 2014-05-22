From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/9] net: Introduce a software TSO helper API
Date: Thu, 22 May 2014 14:58:05 -0400 (EDT)
Message-ID: <20140522.145805.1022840326808986379.davem@davemloft.net>
References: <1400518800-6111-1-git-send-email-ezequiel.garcia@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, w@1wt.eu,
	thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com,
	sebastian.hesselbarth@gmail.com, tawfik@marvell.com,
	alior@marvell.com
To: ezequiel.garcia@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41384 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752247AbaEVS6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 14:58:10 -0400
In-Reply-To: <1400518800-6111-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Date: Mon, 19 May 2014 13:59:51 -0300

> Here's a first proposal for a generic software TSO helper API, following
> David's suggestion.

I like it, applied to net-next, thanks!
