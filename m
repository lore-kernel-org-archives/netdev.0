From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] be2net: patch-set
Date: Wed, 07 Sep 2016 22:47:17 -0700 (PDT)
Message-ID: <20160907.224717.2076352680190588868.davem@davemloft.net>
References: <20160907142754.13284-1-sriharsha.basavapatna@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sriharsha.basavapatna@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54454 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753732AbcIHGWY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 02:22:24 -0400
In-Reply-To: <20160907142754.13284-1-sriharsha.basavapatna@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Date: Wed,  7 Sep 2016 19:57:48 +0530

> The following patch set contains an error recovery feature and a few
> bug fixes. Please consider applying this to the net-next tree. Thanks.
> 
> Patch-1 Supports HW error recovery in Skyhawk/BEx adapters
> Patch-2 Fixes driver unload to issue function reset FW command
> Patch-3 Avoids issuing GET_EXT_FAT_CAPABILITIES command for VFs
> Patch-4 Avoids redundant addition of mac address in HW
> Patch-5 Fixes mac address collision in some configurations
> Patch-6 Updates driver version

Series applied, thanks.
