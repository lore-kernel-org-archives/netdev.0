From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next 03/25] bonding: convert packets_per_slave to
 use the new option API
Date: Wed, 22 Jan 2014 14:09:46 +0100
Message-ID: <52DFC31A.2010908@redhat.com>
References: <1390316114-17815-1-git-send-email-nikolay@redhat.com> <1390316114-17815-4-git-send-email-nikolay@redhat.com> <20140122072528.GD28225@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59527 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755453AbaAVNOS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jan 2014 08:14:18 -0500
In-Reply-To: <20140122072528.GD28225@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/22/2014 08:25 AM, Hannes Frederic Sowa wrote:
> Hi Nikolay!
> 
> On Tue, Jan 21, 2014 at 03:54:52PM +0100, Nikolay Aleksandrov wrote:
>> This patch adds the necessary changes so packets_per_slave would use the
>> new bonding option API.
> 
> Just want to warn you that because of the reciproal_divide merge in net-next
> there will be some conflicts with this patch in net-next.
> 
> I actually looked to rebase Daniel and my series on your patchset, but now
> David pulled ours first.
> 
> Greetings,
> 
>   Hannes
> 
Hi Hannes,
Thanks for the heads up, I just synced net-next with your changes and indeed
there're a few conflicts.
I'll rebase on top of them and post a v2, shouldn't be a problem :-)

Cheers,
 Nik
