From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: allow configuring default qdisc
Date: Wed, 12 Apr 2017 21:57:08 -0400 (EDT)
Message-ID: <20170412.215708.5809846349208399.davem@davemloft.net>
References: <20170408193946.18469-1-sthemmin@microsoft.com>
        <20170411.220959.313852914647879245.davem@davemloft.net>
        <20170412155925.4bd3ed5e@xeon-e3>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sthemmin@microsoft.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53072 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755174AbdDMB5J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 21:57:09 -0400
In-Reply-To: <20170412155925.4bd3ed5e@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Wed, 12 Apr 2017 15:59:25 -0700

> The most recent example was in the block layer.

Linus complained about this, loudly.
