From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dsa: do not dereference non-existing routing table
Date: Sat, 07 Feb 2015 22:08:10 -0800 (PST)
Message-ID: <20150207.220810.190869499622770191.davem@davemloft.net>
References: <20150205135206.GA29383@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tobias@waldekranz.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46759 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736AbbBHGIL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Feb 2015 01:08:11 -0500
In-Reply-To: <20150205135206.GA29383@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Waldekranz <tobias@waldekranz.com>
Date: Thu, 5 Feb 2015 14:52:06 +0100

> In the case where there is only one switch, no routing table will have
> been allocated, so do not dereference it in this case.
> 
> Signed-off-by: Tobias Waldekranz <tobias@waldekranz.com>

Applied.
