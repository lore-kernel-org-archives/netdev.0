From: Matthias Brugger <mbrugger@suse.com>
Subject: Re: [PATCH 0/5] net: thunderx: Miscellaneous fixes
Date: Mon, 14 Nov 2016 18:35:29 +0100
Message-ID: <2908a070-954b-d533-a448-b8ab6c61a577@suse.com>
References: <1479120886-13425-1-git-send-email-sunil.kovvuri@gmail.com>
 <2948c47d-0f15-8153-440b-7a2c753b7251@suse.com>
 <20161114.123253.476733911183519472.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sunil.kovvuri@gmail.com, netdev@vger.kernel.org,
        sgoutham@cavium.com, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nue.novell.com ([195.135.221.5]:57383 "EHLO
        smtp.nue.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933813AbcKNRfp (ORCPT
        <rfc822;groupwise-netdev@vger.kernel.org:0:0>);
        Mon, 14 Nov 2016 12:35:45 -0500
In-Reply-To: <20161114.123253.476733911183519472.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 11/14/2016 06:32 PM, David Miller wrote:
> From: Matthias Brugger <mbrugger@suse.com>
> Date: Mon, 14 Nov 2016 13:01:25 +0100
>
>>
>>
>> On 14/11/16 11:54, sunil.kovvuri@gmail.com wrote:
>>> From: Sunil Goutham <sgoutham@cavium.com>
>>>
>>> This patchset includes fixes for incorrect LMAC credits,
>>> unreliable driver statistics, memory leak upon interface
>>> down e.t.c
>>>
>>
>> Are these fixes relevant to for older kernels as well?
>> If so, please add "Cc: stable@vger.kernel.org" to the Sigend-off list.
>
> This is not appropriate for networking patches.
>
> People instead explicitly request -stable inclusion when the
> submit networking changes to me, and I queue them up for
> later submission.
>

Ok, thanks for clarification.
