From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH v3] can: Fix kernel panic at security_sock_rcv_skb
Date: Fri, 10 Feb 2017 18:50:24 +0100
Message-ID: <fc6909da-b957-e0d5-6a24-7e8c8fdca278@hartkopp.net>
References: <1485533504.6360.62.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170129.183406.1410276231781823069.davem@davemloft.net>
 <9f8cc561-e1e6-c2f6-2bcc-3fe0282ca05c@hartkopp.net>
 <20170210.101629.2041075564534598861.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, stable@vger.kernel.org,
        netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.219]:34451 "EHLO
        mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752602AbdBJRxC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 12:53:02 -0500
In-Reply-To: <20170210.101629.2041075564534598861.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/10/2017 04:16 PM, David Miller wrote:
> From: Oliver Hartkopp <socketcan@hartkopp.net>
> Date: Fri, 10 Feb 2017 09:28:57 +0100
>
>> can you please check whether this upstream commit
>>
>> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=f1712c73714088a7252d276a57126d56c7d37e64
>>
>> really was queued up for -stable?
>
> You never need to ask me this question, it is presented always, here:
>
> 	http://patchwork.ozlabs.org/bundle/davem/stable/?submitter=&state=*&q=&archive=
>
> And it is indeed there.
>

Actually I was only aware of

	http://patchwork.ozlabs.org/project/netdev/list/?state=*

which I checked before asking (of course). But there's no chance to 
figure out whether a patch is queued for -stable.

I'll put your stable queue URL into my bookmarks.

Thanks,
Oliver
