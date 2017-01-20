From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ipv6: Keep nexthop of multipath route on
 admin down
Date: Thu, 19 Jan 2017 23:40:03 -0500 (EST)
Message-ID: <20170119.234003.689273769308227830.davem@davemloft.net>
References: <1484754036-26807-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43750 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751059AbdATEkF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 23:40:05 -0500
In-Reply-To: <1484754036-26807-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Wed, 18 Jan 2017 07:40:36 -0800

> IPv6 deletes route entries associated with multipath routes on an
> admin down where IPv4 does not. For example:
 ...
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Seems reasonable, applied, thanks David.
