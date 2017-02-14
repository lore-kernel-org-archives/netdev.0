From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v6 0/2] qed*: Add support for PTP
Date: Tue, 14 Feb 2017 15:14:20 -0500 (EST)
Message-ID: <20170214.151420.31347870149815362.davem@davemloft.net>
References: <1487088205-21578-1-git-send-email-Yuval.Mintz@cavium.com>
        <20170214.144351.675778032610245493.davem@davemloft.net>
        <BL2PR07MB230680F7B0E85799B0DA58C48D580@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, richardcochran@gmail.com,
        Sudarsana.Kalluru@cavium.com
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42190 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754929AbdBNUOW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 15:14:22 -0500
In-Reply-To: <BL2PR07MB230680F7B0E85799B0DA58C48D580@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Date: Tue, 14 Feb 2017 20:12:52 +0000

>> > This patch series adds required changes for qed/qede drivers for
>> > supporting the IEEE Precision Time Protocol (PTP).
>> > 
>> > Dave,
>> > Please consider applying this series to "net-next".
> 
>> Please fix the problems reported by the kbuild robot.
> 
>> Thanks.
> 
> Fixing those are trivial [simply setting the variables to 0 on declaration],
> but I actually believe those are false positives.
> Still, if you want me to re-spin v7 for this - I'll send it tomorrow.

Yes I want you to respin.  If the kbuild robot reports something you have
to fix it up.
