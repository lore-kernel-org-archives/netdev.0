From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] net: thunderx: Miscellaneous fixes
Date: Mon, 14 Nov 2016 12:32:53 -0500 (EST)
Message-ID: <20161114.123253.476733911183519472.davem@davemloft.net>
References: <1479120886-13425-1-git-send-email-sunil.kovvuri@gmail.com>
        <2948c47d-0f15-8153-440b-7a2c753b7251@suse.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sunil.kovvuri@gmail.com, netdev@vger.kernel.org,
        sgoutham@cavium.com, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: mbrugger@suse.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2948c47d-0f15-8153-440b-7a2c753b7251@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matthias Brugger <mbrugger@suse.com>
Date: Mon, 14 Nov 2016 13:01:25 +0100

> 
> 
> On 14/11/16 11:54, sunil.kovvuri@gmail.com wrote:
>> From: Sunil Goutham <sgoutham@cavium.com>
>>
>> This patchset includes fixes for incorrect LMAC credits,
>> unreliable driver statistics, memory leak upon interface
>> down e.t.c
>>
> 
> Are these fixes relevant to for older kernels as well?
> If so, please add "Cc: stable@vger.kernel.org" to the Sigend-off list.

This is not appropriate for networking patches.

People instead explicitly request -stable inclusion when the
submit networking changes to me, and I queue them up for
later submission.
