From: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
Subject: Re: [Patch v5 0/2] net: ethernet: xilinx: mac addr and mips
Date: Mon, 5 Sep 2016 13:06:50 +0100
Message-ID: <16430098-df1e-6f69-dcc0-f96ce74d890e@imgtec.com>
References: <1472816366-1018-1-git-send-email-Zubair.Kakakhel@imgtec.com>
 <20160904.114518.1390837075013938788.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <michal.simek@xilinx.com>, <soren.brinkmann@xilinx.com>,
        <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailapp01.imgtec.com ([195.59.15.196]:15788 "EHLO
        mailapp01.imgtec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755859AbcIEMHD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Sep 2016 08:07:03 -0400
In-Reply-To: <20160904.114518.1390837075013938788.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09/04/2016 07:45 PM, David Miller wrote:
> From: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
> Date: Fri, 2 Sep 2016 12:39:24 +0100
>
>> A couple of simple patches to generate the random mac address
>> if none is found. And enabling the driver for mips.
>>
>> Based on v4.8-rc4.
>>
>> These were part of a larger series but that series is growing
>> wildly. Splitting and submitting the net subsystem patches separately.
>> Hence the v5.
>
> This doesn't apply cleanly to any of my trees.
>

:)

Looks like there is an identical patch by someone else already in net-next.

https://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/drivers/net/ethernet/xilinx/xilinx_emaclite.c?id=5575cf133cf7f564da991595c6bc9344afa7d89a

Regards,
ZubairLK
