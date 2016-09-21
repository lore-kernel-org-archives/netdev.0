From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mlxsw: spectrum: Make offloads stats
 functions static
Date: Wed, 21 Sep 2016 00:49:55 -0400 (EDT)
Message-ID: <20160921.004955.557242804342186857.davem@davemloft.net>
References: <1474348448-13724-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@mellanox.com, nogahf@mellanox.com, netdev@vger.kernel.org
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33738 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750785AbcIUEt6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 00:49:58 -0400
In-Reply-To: <1474348448-13724-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Tue, 20 Sep 2016 08:14:08 +0300

> The offloads stats functions are local to this file, make them static.
> 
> Fixes: fc1bbb0f1831 ('mlxsw: spectrum: Implement offload stats ndo [..]')
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>

Applied.
