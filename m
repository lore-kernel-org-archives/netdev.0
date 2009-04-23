From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: IMQ bug: kernel reboot immediately
Date: Thu, 23 Apr 2009 12:23:47 +0200 (CEST)
Message-ID: <alpine.LSU.2.00.0904231223050.18687@fbirervta.pbzchgretzou.qr>
References: <20090423084323.GA5696@ff.dom.local> <49F040E8.80402@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jarek Poplawski <jarkao2@gmail.com>, "Y. D." <duyuyang@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <49F040E8.80402@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 2009-04-23 12:20, Patrick McHardy wrote:

>>> Is IMQ still maintained? I am using IMQ to shape ingress traffic.
>>> But the application is a streaming server (VLC). However, the kernel
>>> reboots immediately as quick as can hardly been seen what is
>>> wrong with it.
>>>
>>> Any help with this kinda problem?
>>
>> IMQ isn't a part of kernel/netfilter, so you should try at its own
>> site/mailing list.
>
> I'd rather suggest to get rid of it and use ifb, AFAIK there hasn't
> been a single version in all those years that didn't cause this kind
> of problems.

I'd rather point out that ifb does not seem to be able to do all of what 
IMQ can, up to the point where it is believed in the public that ifb is 
practically useless.
