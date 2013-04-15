From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH 0/3] Dual EMAC mode implementation of CPSW
Date: Mon, 15 Apr 2013 23:04:05 +0530
Message-ID: <516C3A0D.70903@ti.com>
References: <1360612340-9266-1-git-send-email-mugunthanvnm@ti.com> <516B0098.4040809@mimc.co.uk> <516C33D2.4050105@ti.com> <516C38B9.50904@mimc.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>
To: Mark Jackson <mpfj-list@mimc.co.uk>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <516C38B9.50904@mimc.co.uk>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/15/2013 10:58 PM, Mark Jackson wrote:
> On 15/04/13 18:07, Mugunthan V N wrote:
>> On 4/15/2013 12:46 AM, Mark Jackson wrote:
>
> <snip>
>
>>>
>>> Notice that at the end, the nfs link appears to come back "ok", but
>>> the "ps" command never completes.
>>>
>>> Any ideas of what's going on ?
>>
>> I have tried ping on both the interface fine. Will verify with ps again
>> later in this week.
>> Can you provide below details details
>> - Are you using EVMsk or custom build EVM?
>
> This is a custom board (based on the BeagleBone design) with dual 
> Ethernet, NAND, NOR and FRAM.
>
> The dual emac thing is (one of) the last things to get signed off, so 
> I'm willing to assist in tracking this down.

After testing the scenario i may be able to send you an update later in 
this week.

Regards
Mugunthan V N
