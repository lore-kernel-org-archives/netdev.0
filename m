From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/6] FUJITSU Extended Socket driver version
 1.2
Date: Fri, 14 Oct 2016 12:05:14 -0400 (EDT)
Message-ID: <20161014.120514.100603981953874241.davem@davemloft.net>
References: <1476444345-28673-1-git-send-email-izumi.taku@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: izumi.taku@jp.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48826 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752443AbcJNQFQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 12:05:16 -0400
In-Reply-To: <1476444345-28673-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Date: Fri, 14 Oct 2016 20:25:44 +0900

> This patchset updates FUJITSU Extended Socket network driver into version 1.2.
> This includes the following enhancements:
>   - ethtool -d support
>   - ethtool -S enhancement
>   - ethtool -w/-W support
>   - Add some debugging feature (tracepoints etc)
> 
> v1 -> v2:
>   - Use u64 instead of phys_addr_t as TP_STRUCT__entry
>   - Use ethtool facility to achieve debug mode instead of using debugfs

Series applied, thanks.
