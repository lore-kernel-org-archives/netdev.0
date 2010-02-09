From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: netfilter 00/05: netfilter fixes
Date: Tue, 9 Feb 2010 19:19:47 +0100 (CET)
Message-ID: <alpine.LSU.2.01.1002091918310.10859@obet.zrqbmnf.qr>
References: <20100208171024.15522.8136.sendpatchset@x2.localnet> <20100208.111517.197143656.davem@davemloft.net> <4B719C5D.9060402@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B719C5D.9060402@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 2010-02-09 18:33, Patrick McHardy wrote:

>David Miller wrote:
>> From: Patrick McHardy <kaber@trash.net>
>> Date: Mon,  8 Feb 2010 18:10:26 +0100 (MET)
>> 
>>> Please apply or pull from:
>>>
>>> git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git master
>>>
>>> Please note: I forgot to add "Cc: stable@kernel.org" to two of these
>>> patches and manually added it to the patch files, so I'd appreciate
>>> if you could apply the patches manually instead of pulling from the
>>> git tree this time.
>> 
>> Ok, I'll apply these by hand.
>
>Thanks Dave. I plan to submit a first batch of patches queued for
>net-next-2.6 soon, however these fixes introduced a large number
>of conflicts. If you could merge net-2.6 into net-next-2.6 I'll
>resolve them and send a pull request.

Ah that is a good opportunity then to rebase my pending -next patches, 
to reduce conflicts you would have to solve when merging things after 
the conflict resolution.
