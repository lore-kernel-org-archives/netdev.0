From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] cxgb4/cxgbvf: Handle 32-bit fw port
 capabilities
Date: Sun, 20 Aug 2017 19:52:32 -0700 (PDT)
Message-ID: <20170820.195232.1129948557882734273.davem@davemloft.net>
References: <1503218751-24948-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com,
        indranil@chelsio.com, leedom@chelsio.com, venkatesh@chelsio.com
To: ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48990 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753500AbdHUCwd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Aug 2017 22:52:33 -0400
In-Reply-To: <1503218751-24948-1-git-send-email-ganeshgr@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ganesh Goudar <ganeshgr@chelsio.com>
Date: Sun, 20 Aug 2017 14:15:51 +0530

> Implement new 32-bit Firmware Port Capabilities in order to
> handle new speeds which couldn't be represented in the old 16-bit
> Firmware Port Capabilities values.
> 
> Based on the original work of Casey Leedom <leedom@chelsio.com>
> 
> Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
> ---
> v2: Fixes build error when DCB is enabled

Applied.
