From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cpsw: ethtool: add support for nway reset
Date: Wed, 30 Nov 2016 10:13:49 -0500 (EST)
Message-ID: <20161130.101349.1062107841922687589.davem@davemloft.net>
References: <1480326472-5849-1-git-send-email-yegorslists@googlemail.com>
        <20161129.194158.1482957574907674651.davem@davemloft.net>
        <CAGm1_ktxyxVxYdF0Aq-Nv2rVGjEccPsGRZSXHBOE9egybiV1Lg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-omap@vger.kernel.org,
        grygorii.strashko@ti.com, mugunthanvnm@ti.com
To: yegorslists@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:32984 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933648AbcK3PNv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 10:13:51 -0500
In-Reply-To: <CAGm1_ktxyxVxYdF0Aq-Nv2rVGjEccPsGRZSXHBOE9egybiV1Lg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yegor Yefremov <yegorslists@googlemail.com>
Date: Wed, 30 Nov 2016 10:31:30 +0100

> Hi David,
> 
> On Wed, Nov 30, 2016 at 1:41 AM, David Miller <davem@davemloft.net> wrote:
>> From: yegorslists@googlemail.com
>> Date: Mon, 28 Nov 2016 10:47:52 +0100
>>
>>> From: Yegor Yefremov <yegorslists@googlemail.com>
>>>
>>> This patch adds support for ethtool's '-r' command. Restarting
>>> N-WAY negotiation can be useful to activate newly changed EEE
>>> settings etc.
>>>
>>> Signed-off-by: Yegor Yefremov <yegorslists@googlemail.com>
>>
>> This doesn't apply cleanly to net-next.
> 
> My previous patch [1] doesn't show up in net-next. This could explain,
> why nway patch doesn't apply.
> Should I resend them both as series?
> 
> [1] http://marc.info/?l=linux-omap&m=148036822211869&w=2

My bad, I sorted this out and applied the nway-reset patch too.

Sorry about that.
