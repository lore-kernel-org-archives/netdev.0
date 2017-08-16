From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] vmbus sendpacket cleanups
Date: Wed, 16 Aug 2017 16:27:59 -0700 (PDT)
Message-ID: <20170816.162759.185307627595912014.davem@davemloft.net>
References: <20170816155626.16580-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com,
        devel@linuxdriverproject.org, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40908 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752444AbdHPX2C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 19:28:02 -0400
In-Reply-To: <20170816155626.16580-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Wed, 16 Aug 2017 08:56:23 -0700

> These patches remove and consolidate vmbus_sendpacket functions.
> 
> They should go through the net-next tree since these API's
> were only used by the netvsc driver.

Series applied, thanks.
