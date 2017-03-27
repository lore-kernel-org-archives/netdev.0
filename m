From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ibmveth: Remove unused stats member from
 struct ibmveth_adapter
Date: Mon, 27 Mar 2017 16:02:14 -0700 (PDT)
Message-ID: <20170327.160214.1332894631347406443.davem@davemloft.net>
References: <20170327065615.27215-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tlfalcon@linux.vnet.ibm.com, netdev@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52814 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752944AbdC0XCk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 19:02:40 -0400
In-Reply-To: <20170327065615.27215-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Mon, 27 Mar 2017 08:56:15 +0200

> The ibmveth driver keeps its statistics in net_device->stats, so the
> stats member in struct ibmveth_adapter is unused. Remove it.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied.
