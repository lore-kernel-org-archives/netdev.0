From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 2/2] net: phonet: mark phonet_protocol as const
Date: Sat, 07 Oct 2017 23:16:06 +0100 (WEST)
Message-ID: <20171007.231606.385448704494266071.davem@davemloft.net>
References: <1507225235-46033-1-git-send-email-xiaolou4617@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: courmisch@gmail.co, netdev@vger.kernel.org
To: xiaolou4617@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42924 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753192AbdJGWQX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Oct 2017 18:16:23 -0400
In-Reply-To: <1507225235-46033-1-git-send-email-xiaolou4617@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lin Zhang <xiaolou4617@gmail.com>
Date: Fri,  6 Oct 2017 01:40:35 +0800

> The phonet_protocol structs don't need to be written by anyone and
> so can be marked as const.
> 
> Signed-off-by: Lin Zhang <xiaolou4617@gmail.com>

Applied.
