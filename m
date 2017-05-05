From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] misplaced EXPORT_SYMBOL_GPL(ping_hash) in
 net/ipv4/ping.c
Date: Fri, 05 May 2017 12:44:59 -0400 (EDT)
Message-ID: <20170505.124459.404856858262857746.davem@davemloft.net>
References: <20170505161716.6752-1-vdronov@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vdronov@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45748 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750977AbdEEQpA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 5 May 2017 12:45:00 -0400
In-Reply-To: <20170505161716.6752-1-vdronov@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladis Dronov <vdronov@redhat.com>
Date: Fri,  5 May 2017 18:17:16 +0200

> Move misplaced EXPORT_SYMBOL_GPL(ping_hash) to a proper place.
> 
> Signed-off-by: Vladis Dronov <vdronov@redhat.com>

Please use a proper subject line with an appropriate subsystem
prefix.

Also you must indicate the intended target tree (net or net-next)
in the [] brackets.  For example:

	[PATCH net] ipv4: Fix misplaced EXPORT_SYMBOL_GPL ...
