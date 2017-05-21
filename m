From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 4/9] inet: fix warning about missing prototype
Date: Sun, 21 May 2017 13:43:31 -0400 (EDT)
Message-ID: <20170521.134331.1994108164929359964.davem@davemloft.net>
References: <20170519165556.483-1-sthemmin@microsoft.com>
        <20170519165556.483-5-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sthemmin@microsoft.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45198 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756582AbdEURnc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 21 May 2017 13:43:32 -0400
In-Reply-To: <20170519165556.483-5-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Fri, 19 May 2017 09:55:51 -0700

> The prototype for inet_rcv_saddr_equal was not being included.
> 
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>

Applied.
