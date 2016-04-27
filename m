From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: ipv6: Use passed in table for nexthop
 lookups
Date: Wed, 27 Apr 2016 15:37:15 -0400 (EDT)
Message-ID: <20160427.153715.705392661538526385.davem@davemloft.net>
References: <1461558364-17970-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53495 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752388AbcD0ThR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 15:37:17 -0400
In-Reply-To: <1461558364-17970-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Sun, 24 Apr 2016 21:26:04 -0700

> Similar to 3bfd847203c6 ("net: Use passed in table for nexthop lookups")
> for IPv4, if the route spec contains a table id use that to lookup the
> next hop first and fall back to a full lookup if it fails (per the fix
> 4c9bcd117918b ("net: Fix nexthop lookups")).
 ...
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied, thanks David.
