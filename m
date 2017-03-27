From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ibmvnic: Remove unused net_stats member
 from struct ibmvnic_adapter
Date: Mon, 27 Mar 2017 16:02:19 -0700 (PDT)
Message-ID: <20170327.160219.2206810160004593215.davem@davemloft.net>
References: <20170327065659.27307-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tlfalcon@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com,
        netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52828 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752944AbdC0XCf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 19:02:35 -0400
In-Reply-To: <20170327065659.27307-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Mon, 27 Mar 2017 08:56:59 +0200

> The ibmvnic driver keeps its statistics in net_device->stats, so the
> net_stats member in struct ibmvnic_adapter is unused. Remove it.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied.
