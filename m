From: Tommi Rantala <tt.rantala@gmail.com>
Subject: Re: BUG ip_dst_cache (Not tainted): Poison overwritten
Date: Mon, 3 Feb 2014 21:35:24 +0200
Message-ID: <CA+ydwto5CTDSED=pZ_DfAZyh6Jx7xKJafRuDFUtV4ZZCb70ULA@mail.gmail.com>
References: <CA+ydwtrWCgi=v7v=8yjNMV37Aa4ua9zbqYM5_uUdQrLSQt+VEw@mail.gmail.com>
	<1391201873.28432.86.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+ydwtpmFbhkck9z8G7tfHQZW+4rWSepQMgPURqVCwrZ77v2bA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Dave Jones <davej@redhat.com>,
	trinity@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+ydwtpmFbhkck9z8G7tfHQZW+4rWSepQMgPURqVCwrZ77v2bA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2014-02-01 Tommi Rantala <tt.rantala@gmail.com>:
> 2014-01-31 Eric Dumazet <eric.dumazet@gmail.com>:
>> On Fri, 2014-01-31 at 22:11 +0200, Tommi Rantala wrote:
>>> Hello,
>>>
>>> Hit this while fuzzing v3.13-9218-g0e47c96 with trinity in a qemu
>>> virtual machine.
>>>
>>> Tommi
>>
>> Hi Tommi
>>
>> Could you please try the following fix ?
>
> Thanks, giving this a spin. This does not reproduce very easily with
> Trinity, I'll let you know if anything blows up.

Looking good after two days of fuzzing in several virtual machines.
The bug has not been reproduced, and no other ill effects visible.

Thanks!

Tommi
