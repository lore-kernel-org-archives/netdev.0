From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ARM: dts: rk3228-evb: Fix the compiling error
Date: Sun, 27 Aug 2017 16:59:43 -0700 (PDT)
Message-ID: <20170827.165943.359479894499296098.davem@davemloft.net>
References: <1503393865-7975-1-git-send-email-david.wu@rock-chips.com>
        <20170822215251.2125440b@canb.auug.org.au>
        <20170828083254.39430ab3@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david.wu@rock-chips.com, netdev@vger.kernel.org
To: sfr@canb.auug.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56496 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751405AbdH0X7s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Aug 2017 19:59:48 -0400
In-Reply-To: <20170828083254.39430ab3@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 28 Aug 2017 08:32:54 +1000

> Hi Dave (Miller),
> 
> On Tue, 22 Aug 2017 21:52:51 +1000 Stephen Rothwell <sfr@canb.auug.org.au> wrote:
>>
>> Thanks.
>> 
>> On Tue, 22 Aug 2017 17:24:25 +0800 David Wu <david.wu@rock-chips.com> wrote:
>> >
>> > This patch solves the following error:
>> > arch/arm/boot/dts/rk3228-evb.dtb: ERROR (phandle_references): Reference to non-existent node or label "phy0"
>> > 
>> > Fixess db40f15b53e4 ("ARM: dts: rk3228-evb: Enable the integrated PHY for gmac")
>> > Signed-off-by: David Wu <david.wu@rock-chips.com>  
>> 
>> Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
> 
> Ping?

Sorry, I wasn't aware that this should go via my tree, I'll take care of
this soon.
