From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 0/2] TPACKET_V3 TX_RING support
Date: Tue, 03 Jan 2017 11:01:30 -0500 (EST)
Message-ID: <20170103.110130.1667423578879473575.davem@davemloft.net>
References: <cover.1483452545.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, willemb@google.com
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39116 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759517AbdACQBv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 11:01:51 -0500
In-Reply-To: <cover.1483452545.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Tue,  3 Jan 2017 06:31:46 -0800

> This patch series allows an application to use a single PF_PACKET
> descriptor and leverage the best implementations of TX_RING
> and RX_RING that exist today.
> 
> Patch 1 adds the kernel/Documentation changes for TX_RING
> support and patch2 adds the associated test case in selftests.
> 
> Changes since v2: additional sanity checks for setsockopt
> input for TX_RING/TPACKET_V3. Refactored psock_tpacket.c
> test code to avoid code duplication from V2.

Series applied, thanks.
