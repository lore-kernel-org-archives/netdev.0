From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5 net] bridge: Fix missing Netlink message validations
Date: Wed, 26 Nov 2014 15:29:40 -0500 (EST)
Message-ID: <20141126.152940.609250369094871790.davem@davemloft.net>
References: <cover.1417005245.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50473 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750804AbaKZU3m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 15:29:42 -0500
In-Reply-To: <cover.1417005245.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Wed, 26 Nov 2014 13:42:15 +0100

> Adds various missing length checks in the bridging code for Netlink
> messages and corresponding attributes provided by user space.

Series applied, thanks Thomas.
