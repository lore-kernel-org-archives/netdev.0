From: Karl Hiramoto <karl@hiramoto.org>
Subject: Re: [Linux-ATM-General] [PATCH] br2684 testing needed for packet
 loss and performance
Date: Sat, 29 Aug 2009 12:24:39 +0200
Message-ID: <4A9901E7.9040804@hiramoto.org>
References: <200908281225.n7SCPUC3031293@cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: chas3@users.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from caiajhbdccac.dreamhost.com ([208.97.132.202]:42787 "EHLO
	spunkymail-a12.g.dreamhost.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751373AbZH2KYk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2009 06:24:40 -0400
In-Reply-To: <200908281225.n7SCPUC3031293@cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chas Williams (CONTRACTOR) wrote:
> In message <4A97B3A9.6040103@hiramoto.org>,Karl Hiramoto writes:
>   
>> Anyone care to test or comment on  these patches?  I've attached 
>> versions for 2.6.28 and 2.6.30.
>>     
>
> this needs to be against the net-2.6 git repository.  but the 2.6.30
> would probably apply just fine.  
Ok i will resend the patch against net-2.6  or should i do net-next-2.6?

Do i have to wait for a merge window?

> except for the comments, below this
> patch looks fine and makes sense.  a similar thing had to be done for
> the lec.c interface.
>
>   
Ok I'll clean up all these issues.

--
karl
