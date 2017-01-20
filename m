From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: mpls: Fix multipath selection for LSR use case
Date: Fri, 20 Jan 2017 14:49:16 -0500 (EST)
Message-ID: <20170120.144916.1114558876958588985.davem@davemloft.net>
References: <1484873463-11699-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rshearma@brocade.com,
        roopa@cumulusnetworks.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37316 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753032AbdATTzs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 14:55:48 -0500
In-Reply-To: <1484873463-11699-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Thu, 19 Jan 2017 16:51:03 -0800

> MPLS multipath for LSR is broken -- always selecting the first nexthop
> in the one label case. For example:
 ...

David, this doesn't apply cleanly to the net tree, please respin.

Thanks.
