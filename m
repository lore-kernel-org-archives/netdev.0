From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2 net-next] mlxsw: spectrum: Add missing error code
 on allocation failure
Date: Tue, 03 Oct 2017 10:27:14 -0700 (PDT)
Message-ID: <20171003.102714.153187853698749528.davem@davemloft.net>
References: <20171003105303.u7yrzxknddmmerol@mwanda>
        <20171003105340.llwk5oajgrohbksu@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@mellanox.com, yotamg@mellanox.com, idosch@mellanox.com,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47714 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751229AbdJCR1P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 13:27:15 -0400
In-Reply-To: <20171003105340.llwk5oajgrohbksu@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 3 Oct 2017 13:53:41 +0300

> We accidentally return success if the kmalloc_array() call fails.
> 
> Fixes: 0e14c7777acb ("mlxsw: spectrum: Add the multicast routing hardware logic")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
