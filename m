From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: bridge: notify on hw fdb takeover
Date: Mon, 17 Apr 2017 13:45:49 -0400 (EDT)
Message-ID: <20170417.134549.136665384930126255.davem@davemloft.net>
References: <1492166974-20578-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        bridge@lists.linux-foundation.org, stephen@networkplumber.org,
        idosch@mellanox.com
To: nikolay@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56020 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752223AbdDQRpv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 13:45:51 -0400
In-Reply-To: <1492166974-20578-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Fri, 14 Apr 2017 13:49:34 +0300

> Recently we added support for SW fdbs to take over HW ones, but that
> results in changing a user-visible fdb flag thus we need to send a
> notification, also it's consistent with how HW takes over SW entries.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied.
