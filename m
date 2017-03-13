From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] netvsc: fix module removal hangs
Date: Sun, 12 Mar 2017 23:15:58 -0700 (PDT)
Message-ID: <20170312.231558.1410157291433003950.davem@davemloft.net>
References: <20170309230415.8854-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kys@microsoft.com, haiyangz@microsoft.com, netdev@vger.kernel.org,
        sthemmin@microsoft.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53316 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750703AbdCMGQA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 02:16:00 -0400
In-Reply-To: <20170309230415.8854-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Thu,  9 Mar 2017 15:04:13 -0800

> A couple of patches are necessary to make netvsc driver module
> removable again.

Series applied, thanks.
