From: Patrick McHardy <kaber@trash.net>
Subject: Re: netfilter 00/05: netfilter fixes
Date: Tue, 05 May 2009 14:33:05 +0200
Message-ID: <4A003201.2010301@trash.net>
References: <20090424154355.28952.21443.sendpatchset@x2.localnet> <20090425.175758.05225143.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090425.175758.05225143.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Fri, 24 Apr 2009 17:44:01 +0200 (MEST)
> 
>> Please apply or pull from:
>>
>> git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git
> 
> Pulled, thanks Patrick.
> 
> It would be nice to see this fixed:
> 
>   CHECK   include/linux/netfilter (57 files)
> /home/davem/src/GIT/net-2.6/usr/include/linux/netfilter/xt_LED.h:6: found __[us]{8,16,32,64} type without #include <linux/types.h>

Appologies for my silence over the past week, holidays and a swine
cold kept me away from the computer .)

I've queued a fix for this, thanks.
