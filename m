From: Kurt Van Dijck <kurt.van.dijck@eia.be>
Subject: Re: [PATCH] can: Fix CAN_(EFF|RTR)_FLAG handling in can_filter
Date: Tue, 2 Dec 2008 11:01:35 +0100
Message-ID: <20081202100134.GA2650@e-circ.dyndns.org>
References: <20081128153317.GA3726@e-circ.dyndns.org> <49340DAE.5060603@hartkopp.net> <20081201175225.GA1835@uranus.ravnborg.org> <49343017.202@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Sam Ravnborg <sam@ravnborg.org>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	David Miller <davem@davemloft.net>, Greg KH <greg@kroah.com>,
	Linux Netdev List <netdev@vger.kernel.org>, stable@kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.eia.be ([194.78.71.18]:58470 "EHLO mail.eia.be"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751810AbYLBKRD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Dec 2008 05:17:03 -0500
Content-Disposition: inline
In-Reply-To: <49343017.202@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 01, 2008 at 07:42:31PM +0100, Oliver Hartkopp wrote:
> Sam Ravnborg wrote:
>> On Mon, Dec 01, 2008 at 05:15:42PM +0100, Oliver Hartkopp wrote:
>>   
>>>
>>> Thanks to Kurt Van Dijck for pointing at this issue and for the review.
>>>
>>> Signed-Off-by: Oliver Hartkopp <oliver@hartkopp.net>
>>> Acked-by: Kurt Van Dijck <kurt.van.dijck@eia.be>
>>>     
>>
>> If Kurt tested this patch then he should
>> be credited with a "Tested-by:" tag.
>>
>> I recall he did but I deleted the thread from my can mailbox.
>>
>> 	Sam
>>   
> Hi Sam,
>
> i did some testing and posted the results of a first patch that went  
> into the final direction.
>
> In
>
> https://lists.berlios.de/pipermail/socketcan-core/2008-December/002117.html
>
> Kurt gave a "Reviewed-by:" and in a later mail in
>
> https://lists.berlios.de/pipermail/socketcan-core/2008-December/002119.html
>
> he wrote "my Acked-by: still stands" for the final patch.
>
> So i choosed "Acked-by:".
>
> As Kurt went that deep into the code that he pointed me to the right  
> line and presented a first idea for a patch, an 'Acked-by:' for  
> confirming the final patch looked like an appropriate credit to me.
Well, I did not physically test Oliver's final patch, which looked totally
different.
By lack of time, did not take the effort of completely testing it again. The test
scenario included the problematic scenario, which made me think Oliver
understood the problem.
For the final patch, a 'Acked-by:' looks appropriate to me too.
Sam,
I'm pleased to notice the credits are watched this close too.
>
> Regards,
> Oliver
>
Kurt
