From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 3/3] udp: try to avoid 2 cache miss on
 dequeue
Date: Fri, 09 Jun 2017 12:33:28 -0400 (EDT)
Message-ID: <20170609.123328.2129589893216826097.davem@davemloft.net>
References: <1496822205.2409.1.camel@redhat.com>
        <20170607.101056.833234534371053047.davem@davemloft.net>
        <1497023069.3416.18.camel@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33694 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751560AbdFIQda (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 12:33:30 -0400
In-Reply-To: <1497023069.3416.18.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Fri, 09 Jun 2017 17:44:29 +0200

> I'll re-submit v3 unchanged, if there are no objections.

No objections from me.
