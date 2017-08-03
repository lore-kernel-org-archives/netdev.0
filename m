From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] ibmvnic: Improve ethtool functionality
Date: Thu, 03 Aug 2017 09:33:22 -0700 (PDT)
Message-ID: <20170803.093322.461073682425584670.davem@davemloft.net>
References: <f89ddaab-fe27-2b3c-5b3a-3aaac1e60ae3@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tlfalcon@linux.vnet.ibm.com,
        nfont@linux.vnet.ibm.com
To: jallen@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45292 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751206AbdHCQdX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 12:33:23 -0400
In-Reply-To: <f89ddaab-fe27-2b3c-5b3a-3aaac1e60ae3@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Allen <jallen@linux.vnet.ibm.com>
Date: Wed, 2 Aug 2017 16:42:49 -0500

> This patch series improves ibmvnic ethtool functionality by adding support
> for ethtool -l and -g options, correcting existing statistics reporting,
> and augmenting the existing statistics with counters for each tx and rx
> queue.

Series applied, thanks.
