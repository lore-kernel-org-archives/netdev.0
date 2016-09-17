From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: vrf: Remove RT_FL_TOS
Date: Sat, 17 Sep 2016 10:05:36 -0400 (EDT)
Message-ID: <20160917.100536.393179536390922448.davem@davemloft.net>
References: <1473959627-5268-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60172 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751258AbcIQOFj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2016 10:05:39 -0400
In-Reply-To: <1473959627-5268-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Thu, 15 Sep 2016 10:13:47 -0700

> No longer used after d66f6c0a8f3c0 ("net: ipv4: Remove l3mdev_get_saddr")
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied.
