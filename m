From: Stephen Clark <sclark46@earthlink.net>
Subject: Re: [PATCH v2] net-tcp: TCP/IP stack bypass for loopback connections
Date: Thu, 23 Aug 2012 12:41:48 -0400
Message-ID: <50365D4C.4000609@earthlink.net>
References: <1344559958-29162-1-git-send-email-brutus@google.com>	<20120814023155.ffe9c01d.billfink@mindspring.com> <20120814.003732.714549073635415560.davem@davemloft.net>
Reply-To: sclark46@earthlink.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: billfink@mindspring.com, brutus@google.com, edumazet@google.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-scoter.atl.sa.earthlink.net ([209.86.89.67]:39360 "EHLO
	elasmtp-scoter.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754773Ab2HWRCg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 13:02:36 -0400
In-Reply-To: <20120814.003732.714549073635415560.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/14/2012 03:37 AM, David Miller wrote:
> From: Bill Fink<billfink@mindspring.com>
> Date: Tue, 14 Aug 2012 02:31:55 -0400
>
>    
>> I also believe it should be disabled by default, as that is
>> the current behavior, and those who would gain an advantage
>> from using it can easily enable it.
>>      
> It benefits basically everyone, it makes things orders of
> magnitude faster.
>    
Hmm... Looking at the stats provided I didn't see any orders of 
magnitude faster.
>    
>> While this could be a very useful feature in some environments,
>> it seems to me it would be safest to have it disabled by default.
>>      
> I violently disagree, and there is no way I'm having this
> thing off by default.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>    


-- 

"They that give up essential liberty to obtain temporary safety,
deserve neither liberty nor safety."  (Ben Franklin)

"The course of history shows that as a government grows, liberty
decreases."  (Thomas Jefferson)
