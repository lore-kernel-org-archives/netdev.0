From: Patrick McHardy <kaber@trash.net>
Subject: Re: netfilter 00/05: netfilter fixes
Date: Mon, 09 Feb 2009 23:47:07 +0100
Message-ID: <4990B26B.3020705@trash.net>
References: <20090209163926.13918.96177.sendpatchset@x2.localnet> <20090209.143238.25276576.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090209.143238.25276576.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Mon,  9 Feb 2009 17:39:27 +0100 (MET)
> 
>> Please apply or pull from:
>>
>> git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git
> 
> I was going to pull from your tree and take it like that, but when I
> pulled I got 5 real changes and 50 merges with net-2.6, yikes! :-)

Ugh sorry, thats happening automatically, but it usually doesn't show
up since it should be fast forwards. I'll have a look at what went
wrong.

> If there was one or two merge changesets in there, I would have
> taken it.  But anything more than that for a tree containing
> 5 bug fixes is excessive.
> 
> I'll apply these as patches, but I really do want to be able to
> pull from your trees so please try to provide a cleaner tree
> next time.

I'll make sure of it, sorry.
