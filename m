From: Patrick McHardy <kaber@trash.net>
Subject: Re: netfilter 00/05: netfilter fixes
Date: Wed, 10 Feb 2010 14:52:09 +0100
Message-ID: <4B72BA09.8000602@trash.net>
References: <20100208171024.15522.8136.sendpatchset@x2.localnet> <20100208.111517.197143656.davem@davemloft.net> <4B719C5D.9060402@trash.net> <alpine.LSU.2.01.1002091918310.10859@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.01.1002091918310.10859@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan Engelhardt wrote:
> On Tuesday 2010-02-09 18:33, Patrick McHardy wrote:
> 
>> Thanks Dave. I plan to submit a first batch of patches queued for
>> net-next-2.6 soon, however these fixes introduced a large number
>> of conflicts. If you could merge net-2.6 into net-next-2.6 I'll
>> resolve them and send a pull request.
> 
> Ah that is a good opportunity then to rebase my pending -next patches, 
> to reduce conflicts you would have to solve when merging things after 
> the conflict resolution.

I've merged the current net-next tree and pushed it out.
