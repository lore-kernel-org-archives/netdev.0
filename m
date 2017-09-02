From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] netvsc: transparent VF related cleanups
Date: Fri, 01 Sep 2017 20:31:31 -0700 (PDT)
Message-ID: <20170901.203131.1119745772527334553.davem@davemloft.net>
References: <20170831231613.15805-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com,
        devel@linuxdriverproject.org, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57976 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750941AbdIBDbc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 23:31:32 -0400
In-Reply-To: <20170831231613.15805-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Thu, 31 Aug 2017 16:16:11 -0700

> The first gets rid of unnecessary ref counting, and second
> allows removing hv_netvsc driver even if VF present.

Series applied.
