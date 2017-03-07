From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/5] NAPI support for Hyper-V
Date: Mon, 06 Mar 2017 17:13:33 -0800 (PST)
Message-ID: <20170306.171333.1067660469641044496.davem@davemloft.net>
References: <20170227182651.3956-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sthemmin@microsoft.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50738 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753596AbdCGBO0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 20:14:26 -0500
In-Reply-To: <20170227182651.3956-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 27 Feb 2017 10:26:46 -0800

> These patches enable NAPI, GRO and napi_alloc_skb for Hyper-V netvsc
> driver.

Series applied to net-next.
