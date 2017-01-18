From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] net: ipv6: simplify rt6_fill_node
Date: Wed, 18 Jan 2017 15:44:29 -0500 (EST)
Message-ID: <20170118.154429.1213602974759476773.davem@davemloft.net>
References: <1484697068-20106-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41146 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751585AbdARVQg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 16:16:36 -0500
In-Reply-To: <1484697068-20106-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Tue, 17 Jan 2017 15:51:06 -0800

> Remove a couple of unnecessary input arguments to rt6_fill_node.

Looks good, series applied, thanks.
