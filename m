From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 0/9] macsec: a few fixes
Date: Sun, 24 Apr 2016 14:32:23 -0400 (EDT)
Message-ID: <20160424.143223.1895184978590998205.davem@davemloft.net>
References: <cover.1461315621.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lrichard@redhat.com,
	hannes@stressinduktion.org, johannes@sipsolutions.net,
	dan.carpenter@oracle.com
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52539 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751735AbcDXSca (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Apr 2016 14:32:30 -0400
In-Reply-To: <cover.1461315621.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Fri, 22 Apr 2016 11:28:00 +0200

> Some small fixes for the macsec driver:
>  - possible NULL pointer dereferences
>  - netlink dumps fixes: RTNL locking, consistent dumps
>  - a reference counting bug
>  - wrong name for uapi constant
>  - a few memory leaks
> 
> Patches 1 to 5 are the same as in v1, patches 6 to 9 are new.
> Patch 6 fixes the memleak that Lance spotted in v1.

Series applied, thanks Sabrina.
