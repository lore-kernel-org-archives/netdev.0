From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/4] ixgbe: sparc: rename the
 ARCH_WANT_RELAX_ORDER to IXGBE_ALLOW_RELAXED_ORDER
Date: Thu, 13 Apr 2017 10:53:58 -0400 (EDT)
Message-ID: <20170413.105358.633309964366964915.davem@davemloft.net>
References: <20170401.112603.1991545644693496714.davem@davemloft.net>
        <42428725-89f1-1508-4e3d-723e087b3bbb@huawei.com>
        <EE11001F9E5DDD47B7634E2F8A612F2E205199C0@FRAEML521-MBX.china.huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: catalin.marinas@arm.com, will.deacon@arm.com, mark.rutland@arm.com,
        Robin.Murphy@arm.com, jeffrey.t.kirsher@intel.com,
        alexander.duyck@gmail.com, linux-arm-kernel@lists.infradead.org,
        netdev@vger.kernel.org, dingtianhong@huawei.com,
        linuxarm@huawei.com
To: gabriele.paoloni@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60048 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754026AbdDMOyK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2017 10:54:10 -0400
In-Reply-To: <EE11001F9E5DDD47B7634E2F8A612F2E205199C0@FRAEML521-MBX.china.huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gabriele Paoloni <gabriele.paoloni@huawei.com>
Date: Thu, 13 Apr 2017 09:10:32 +0000

> Wouldn't it be more correct to have this as a driver specific symbol
> now and move it to a generic one later once we have other drivers
> requiring it?

No, it would not.
