From: Knut Petersen <Knut_Petersen@t-online.de>
Subject: Re: [BUG: 3.13.0-rc4] inconsistent lock state
Date: Wed, 18 Dec 2013 08:54:35 +0100
Message-ID: <52B154BB.8040506@t-online.de>
References: <52B09446.7060809@t-online.de> <1387306781.19078.288.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1387306781.19078.288.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 17.12.2013 19:59, Eric Dumazet wrote:
> On Tue, 2013-12-17 at 19:13 +0100, Knut Petersen wrote:
>> Hi Linus / everybody!
>>
>> Booting openSuSE 13.1 with kernel 3.13.0-rc4 triggers the attached
>> warning.
>>
>> cu,
>>    Knut
>>
>>
> Following patch should solve the issue.
>
> http://patchwork.ozlabs.org/patch/301382/

Indeed, it solves the problem.

cu,
  Knut
