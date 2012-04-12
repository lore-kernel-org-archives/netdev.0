From: Massimo cetra <ctrix+debianbugs@navynet.it>
Subject: Re: Kernel panic with bridge networking
Date: Thu, 12 Apr 2012 16:57:06 +0200
Message-ID: <4F86ED42.9030603@navynet.it>
References: <4F86CACB.8010907@navynet.it> <1334235175.5300.6329.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Peter Huang (Peng)" <peter.huangpeng@huawei.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host188-6-static.238-77-b.business.telecomitalia.it ([77.238.6.188]:54048
	"EHLO max.ctrix.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757660Ab2DLO5V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 10:57:21 -0400
In-Reply-To: <1334235175.5300.6329.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/04/2012 14:52, Eric Dumazet wrote:
> On Thu, 2012-04-12 at 14:30 +0200, Massimo Cetra wrote:
>> Hello,
>>
>> i am experiencing a panic whose logs are attached (grabbed with netconsole).
>>

> Known issue, and we are waiting from a fix from Peter.
>
> https://lkml.org/lkml/2012/3/31/17
>
> Peter, any progress on your side ?
>

Thanks Eric,

is there a way to prvent those panics, meanwhile ?
I mean: i don't understand if it depends strictly on IPv6 or it has 
other causes.
The same kernel with ipv6 enabled but without ipv6 is not actually 
panic-ing ...

And thanks to Peter as well.

Massimo
