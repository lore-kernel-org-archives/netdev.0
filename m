From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 5/8] net/ncsi: Dump NCSI packet statistics
Date: Thu, 20 Apr 2017 17:58:58 -0700 (PDT)
Message-ID: <20170420.175858.1747890177363276280.davem@davemloft.net>
References: <1492498295-14385-6-git-send-email-gwshan@linux.vnet.ibm.com>
        <20170420.132103.454438573956782815.davem@davemloft.net>
        <20170420233812.GA7223@gwshan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe@perches.com, kubakici@wp.pl
To: gwshan@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52406 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034205AbdDUA7D (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 20:59:03 -0400
In-Reply-To: <20170420233812.GA7223@gwshan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Date: Fri, 21 Apr 2017 09:38:12 +1000

> (1) ethtool usually dumps statistics collected by hardware, but this
> debugfs file dumps the statistics of packets seen (collected) by
> software.

ethtool is not strictly for hardware statistics, it's often used for
software maintained values
