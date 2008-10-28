From: Patrick McHardy <kaber@trash.net>
Subject: Re: nf-next-2.6.git
Date: Tue, 28 Oct 2008 17:36:13 +0100
Message-ID: <49073F7D.3090108@trash.net>
References: <49070504.1010005@trash.net>	 <1225211021.5269.146.camel@localhost>  <49073E96.9000703@trash.net> <1225211639.5269.148.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1225211639.5269.148.camel@localhost>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches wrote:
> On Tue, 2008-10-28 at 17:32 +0100, Patrick McHardy wrote:
>> Joe Perches wrote:
>>> On Tue, 2008-10-28 at 13:26 +0100, Patrick McHardy wrote:
>>>> Since Dave has created his net-next-2.6.git tree, I'm now also
>>>> taking netfilter patches for 2.6.29. The nf-next-2.6.git tree
>>>> is located at:
>>>>
>>>> git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git
>>> Should either or both of git trees be added to
>>> MAINTAINERS: NETFILTER/IPTABLES/IPCHAINS?
>>>
>>> T:	git.kernel.org/pub/scm/linux/kernel/git/kaber/nft-2.6.git
>>> T:	git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git
>> The first one is a development tree for something not inside
>> the kernel yet. Adding the second one would be fine.
> 
> I believe you got the order reversed.
> 
> This below could/should be added yes?
> 
> T:	git.kernel.org/pub/scm/linux/kernel/git/kaber/nft-2.6.git

No, thats the nftables development tree. That one will reset,
rebase etc. and none of the code inside it is merged.

nf-next-2.6.git is the tree I'll regulary ask Dave to merge.
