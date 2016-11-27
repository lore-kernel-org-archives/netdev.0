From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 09/11] qede: Better utilize the
 qede_[rt]x_queue
Date: Sun, 27 Nov 2016 15:16:31 -0500 (EST)
Message-ID: <20161127.151631.150312523846891505.davem@davemloft.net>
References: <1480258273-24973-10-git-send-email-Yuval.Mintz@cavium.com>
        <201611272330.xRUonBtv%fengguang.wu@intel.com>
        <BL2PR07MB23064E75618105466EAA79A68D8B0@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lkp@intel.com, netdev@vger.kernel.org
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57650 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752072AbcK0UQg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 15:16:36 -0500
In-Reply-To: <BL2PR07MB23064E75618105466EAA79A68D8B0@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Date: Sun, 27 Nov 2016 16:15:42 +0000

> I'd say this is a false positive, given that MTU can't be so large.

False positive or not you must fix the warning and resubmit this
series with that fixed.
