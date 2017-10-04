From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 1/3] bridge: add new BR_NEIGH_SUPPRESS port
 flag to suppress arp and nd flood
Date: Wed, 04 Oct 2017 15:52:55 -0700 (PDT)
Message-ID: <20171004.155255.2208423870631197976.davem@davemloft.net>
References: <1507093953-59929-1-git-send-email-roopa@cumulusnetworks.com>
        <1507093953-59929-2-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com,
        stephen@networkplumber.org, bridge@lists.linux-foundation.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54368 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751120AbdJDWw6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 18:52:58 -0400
In-Reply-To: <1507093953-59929-2-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Tue,  3 Oct 2017 22:12:31 -0700

> BR_ARP_PROXY flag but has a few semantic differences to conform

This should be "BR_PROXYARP".

Otherwise this series looks fine to me, but I see there will be
a v5 respin.
