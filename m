From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: l3mdev: Remove netif_index_is_l3_master
Date: Sat, 17 Sep 2016 10:05:42 -0400 (EDT)
Message-ID: <20160917.100542.1445295121618082642.davem@davemloft.net>
References: <1473959925-22881-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60178 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751258AbcIQOFo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2016 10:05:44 -0400
In-Reply-To: <1473959925-22881-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Thu, 15 Sep 2016 10:18:45 -0700

> No longer used after e0d56fdd73422 ("net: l3mdev: remove redundant calls")
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied.
