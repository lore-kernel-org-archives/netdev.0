From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/5] cxgb4: add support for offloading TC
 u32 filters
Date: Thu, 22 Sep 2016 01:40:26 -0400 (EDT)
Message-ID: <20160922.014026.1076807159358983723.davem@davemloft.net>
References: <cover.1474029677.git.rahul.lakkireddy@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hariprasad@chelsio.com, leedom@chelsio.com,
        nirranjan@chelsio.com, indranil@chelsio.com
To: rahul.lakkireddy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54728 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755615AbcIVFka (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 01:40:30 -0400
In-Reply-To: <cover.1474029677.git.rahul.lakkireddy@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Date: Tue, 20 Sep 2016 17:13:05 +0530

> This series of patches add support to offload TC u32 filters onto
> Chelsio NICs.
> 
> Patch 1 moves current common filter code to separate files
> in order to provide a common api for performing packet classification
> and filtering in Chelsio NICs.
> 
> Patch 2 enables filters for normal NIC configuration and implements
> common api for setting and deleting filters.
> 
> Patches 3-5 add support for TC u32 offload via ndo_setup_tc.

Series applied.
