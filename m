From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] netvsc: performance regressions in
 net-next
Date: Wed, 22 Mar 2017 11:22:43 -0700 (PDT)
Message-ID: <20170322.112243.68905906439537046.davem@davemloft.net>
References: <20170320202805.19362-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kys@microsoft.com, haiyangz@microsoft.com, netdev@vger.kernel.org,
        sthemmin@microsoft.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42634 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965612AbdCVSWp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 14:22:45 -0400
In-Reply-To: <20170320202805.19362-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 20 Mar 2017 13:28:03 -0700

> Fix for performance regression introduced with NAPI change;
> and followup cleanup of vmbus core code.

Series applied, thanks Stephen.
