From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] mpls: fix rtm policy in mpls_getroute
Date: Wed, 05 Jul 2017 09:06:34 +0100 (WEST)
Message-ID: <20170705.090634.215126223174350944.davem@davemloft.net>
References: <1499212982-12970-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsahern@gmail.com, rshearma@brocade.com,
        nikolay@cumulusnetworks.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36612 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752493AbdGEIGl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 04:06:41 -0400
In-Reply-To: <1499212982-12970-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Tue,  4 Jul 2017 17:03:02 -0700

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> fix rtm policy name typo in mpls_getroute and also remove
> export of rtm_ipv4_policy
> 
> Fixes: 397fc9e5cefe ("mpls: route get support")
> Reported-by: David S. Miller <davem@davemloft.net>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
> David, since the rtm_ipv4_policy export is not in net yet
> and assuming it will soon be there, I have generated this
> patch against net-next, but addressed it to net. Thanks.

Applied.
