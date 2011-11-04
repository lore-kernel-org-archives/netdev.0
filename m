From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: clarify attribute length check documentation
Date: Fri, 04 Nov 2011 17:48:48 -0400 (EDT)
Message-ID: <20111104.174848.1182422313813714850.davem@davemloft.net>
References: <1320315005.3950.37.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34094 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753981Ab1KDVuy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2011 17:50:54 -0400
In-Reply-To: <1320315005.3950.37.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Thu, 03 Nov 2011 11:10:05 +0100

> From: Johannes Berg <johannes.berg@intel.com>
> 
> The documentation for how the length of attributes
> is checked is wrong ("Exact length" isn't true, the
> policy checks are for "minimum length") and a bit
> misleading. Make it more complete and explain what
> really happens.
> 
> Cc: Thomas Graf <tgraf@suug.ch>
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>

Applied.
