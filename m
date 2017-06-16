From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2 0/2] pktgen new parameters
Date: Fri, 16 Jun 2017 12:33:26 -0400 (EDT)
Message-ID: <20170616.123326.176483526177838900.davem@davemloft.net>
References: <1497542842-13721-1-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brouer@redhat.com, eranbe@mellanox.com
To: tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33306 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752142AbdFPQdd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 12:33:33 -0400
In-Reply-To: <1497542842-13721-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>
Date: Thu, 15 Jun 2017 19:07:20 +0300

> This patchset adds two parameters to the pktgen scripts.
> * The first patch adds a parameter to control the number of
>   packets sent by every pktgen thread.
> * The second patch adds a parameter to control the index of
>   first thread, instead of always starting from cpu 0.
> 
> Series generated against net-next commit:
> f7aec129a356 rxrpc: Cache the congestion window setting

Series applied, thanks Tariq.
