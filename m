From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: switchdev: Use an helper to clear
 forward mark
Date: Tue, 05 Sep 2017 11:51:56 -0700 (PDT)
Message-ID: <20170905.115156.375758250405492055.davem@davemloft.net>
References: <20170903144413.21946-1-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
        nikolay@cumulusnetworks.com, yotamg@mellanox.com,
        bridge@lists.linux-foundation.org, mlxsw@mellanox.com
To: idosch@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36906 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753324AbdIESv5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 14:51:57 -0400
In-Reply-To: <20170903144413.21946-1-idosch@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>
Date: Sun,  3 Sep 2017 17:44:13 +0300

> Instead of using ifdef in the C file.
> 
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Suggested-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Tested-by: Yotam Gigi <yotamg@mellanox.com>

Applied.
