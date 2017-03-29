From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: mpls: Update lfib_nlmsg_size to skip
 deleted nexthops
Date: Wed, 29 Mar 2017 10:43:03 -0700 (PDT)
Message-ID: <20170329.104303.1890684830413483572.davem@davemloft.net>
References: <1490739589-3039-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49364 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753126AbdC2RnE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 13:43:04 -0400
In-Reply-To: <1490739589-3039-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Tue, 28 Mar 2017 15:19:49 -0700

> A recent commit skips nexthops in a route if the device has been
> deleted. Update lfib_nlmsg_size accordingly.
> 
> Reported-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied, thanks.
