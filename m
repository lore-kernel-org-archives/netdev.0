From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3 0/2] Fix tc-ife bugs
Date: Tue, 27 Sep 2016 09:54:18 -0400 (EDT)
Message-ID: <20160927.095418.207194905343400043.davem@davemloft.net>
References: <1474886726-56363-1-git-send-email-yotamg@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, netdev@vger.kernel.org, mlxsw@mellanox.com,
        yotamg@mellanox.com
To: yotam.gi@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47592 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932749AbcI0NyW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 09:54:22 -0400
In-Reply-To: <1474886726-56363-1-git-send-email-yotamg@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotam.gi@gmail.com>
Date: Mon, 26 Sep 2016 13:45:24 +0300

> This patch-set contains two bugfixes in the tc-ife action, one fixing some
> random behaviour in encode side, and one fixing the decode side packet
> parsing logic.
> 
> v2->v3
>  - Fix the encode side instead of the decode side

Series applied, thanks.
