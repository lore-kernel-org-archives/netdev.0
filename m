From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4/cxgbvf: Handle 32-bit fw port
 capabilities
Date: Sat, 19 Aug 2017 21:32:40 -0700 (PDT)
Message-ID: <20170819.213240.451867452734302860.davem@davemloft.net>
References: <1503071492-4822-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com,
        indranil@chelsio.com, leedom@chelsio.com, venkatesh@chelsio.com
To: ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55950 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751980AbdHTEcl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Aug 2017 00:32:41 -0400
In-Reply-To: <1503071492-4822-1-git-send-email-ganeshgr@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ganesh Goudar <ganeshgr@chelsio.com>
Date: Fri, 18 Aug 2017 21:21:32 +0530

> Implement new 32-bit Firmware Port Capabilities in order to
> handle new speeds which couldn't be represented in the old 16-bit
> Firmware Port Capabilities values.
> 
> Based on the original work of Casey Leedom <leedom@chelsio.com>
> 
> Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>

Applied.
