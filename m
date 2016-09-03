From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] tipc: improve broadcast NACK mechanism
Date: Fri, 02 Sep 2016 17:10:38 -0700 (PDT)
Message-ID: <20160902.171038.1463883926411804442.davem@davemloft.net>
References: <1472752371-30338-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
        parthasarathy.bhuvaragan@ericsson.com, richard.alpe@ericsson.com,
        ying.xue@windriver.com, maloy@donjonn.com,
        tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59212 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751540AbcICAKk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 20:10:40 -0400
In-Reply-To: <1472752371-30338-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Thu,  1 Sep 2016 13:52:48 -0400

> The broadcast protocol has turned out to not scale well beyond 70-80
> nodes, while it is now possible to build TIPC clusters of at least ten
> times that size. This commit series improves the NACK/retransmission
> mechanism of the broadcast protocol to make is at scalable as the rest
> of TIPC.

Series applied, thanks Jon.
