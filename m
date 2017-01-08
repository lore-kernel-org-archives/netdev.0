From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ipv4: Remove flow arg from
 ip_mkroute_input
Date: Sun, 08 Jan 2017 17:14:59 -0500 (EST)
Message-ID: <20170108.171459.1690907081495106072.davem@davemloft.net>
References: <1483753198-16222-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42880 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754840AbdAHWPA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Jan 2017 17:15:00 -0500
In-Reply-To: <1483753198-16222-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Fri,  6 Jan 2017 17:39:58 -0800

> fl4 arg is not used; remove it.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied.
