From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1 0/2] tipc: subscription refcount
 simplifications
Date: Tue, 28 Mar 2017 18:03:45 -0700 (PDT)
Message-ID: <20170328.180345.861484683755748362.davem@davemloft.net>
References: <1490696908-7790-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
        jon.maloy@ericsson.com, maloy@donjonn.com, ying.xue@windriver.com
To: parthasarathy.bhuvaragan@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39942 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932623AbdC2BDw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 21:03:52 -0400
In-Reply-To: <1490696908-7790-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Date: Tue, 28 Mar 2017 12:28:26 +0200

> The first patch makes the subscription refcount cleanup lockless and
> the second updates the subscription refcount policy.

Series applied, thanks.
