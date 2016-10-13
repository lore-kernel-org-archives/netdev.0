From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: bridge: add the multicast_flood flag
 attribute to brport_attrs
Date: Thu, 13 Oct 2016 12:17:29 -0400 (EDT)
Message-ID: <20161013.121729.1428933378256656689.davem@davemloft.net>
References: <1476364852-25777-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
        roopa@cumulusnetworks.com
To: nikolay@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34970 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752516AbcJMQSr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 12:18:47 -0400
In-Reply-To: <1476364852-25777-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Thu, 13 Oct 2016 15:20:52 +0200

> When I added the multicast flood control flag, I also added an attribute
> for it for sysfs similar to other flags, but I forgot to add it to
> brport_attrs.
> 
> Fixes: b6cb5ac8331b ("net: bridge: add per-port multicast flood flag")
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied, thanks.
