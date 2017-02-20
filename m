From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 00/10] qed*: Bug fixes
Date: Mon, 20 Feb 2017 15:40:00 -0500 (EST)
Message-ID: <20170220.154000.195323599467695349.davem@davemloft.net>
References: <1487510783-19919-1-git-send-email-Yuval.Mintz@cavium.com>
        <20170220.103739.96795933381020391.davem@davemloft.net>
        <BL2PR07MB23065BFB31B2BC1031663D7D8D5E0@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42676 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751228AbdBTUkG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 15:40:06 -0500
In-Reply-To: <BL2PR07MB23065BFB31B2BC1031663D7D8D5E0@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Date: Mon, 20 Feb 2017 20:14:17 +0000

>  > > Hi Dave,
>> >
>> > The 3 first patches here are a repost of
>> > ("qed: RoCE infrastructure fixes"). The fourth is an additional
>> > RoCE-related infrastructure fix, and the latter contain various fixes
>> > to qed/qede.
>> >
>> > Notice patch #10 will create a conflict when net and net-next would be
>> > merged [although its fix is quite trivial].
>> >
>> > Please consider applying these to `net'.
>> 
>> Linus made his release so all patches are going into net-next, which this
>> series doesn't apply cleanly to.  Please therefore respin your series against
>> net-next, thanks.
> 
> Just to clarify - do you want me to re-spin the fixes against next-next *now*,
> or do you want me to wait until it re-opens? [not sure on its exact state]

Yes, now.
