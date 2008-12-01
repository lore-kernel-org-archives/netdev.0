From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] can: Fix CAN_(EFF|RTR)_FLAG handling in can_filter
Date: Mon, 01 Dec 2008 19:42:31 +0100
Message-ID: <49343017.202@hartkopp.net>
References: <20081128153317.GA3726@e-circ.dyndns.org> <49340DAE.5060603@hartkopp.net> <20081201175225.GA1835@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Oliver Hartkopp <oliver@hartkopp.net>,
	David Miller <davem@davemloft.net>, Greg KH <greg@kroah.com>,
	Kurt Van Dijck <kurt.van.dijck@eia.be>,
	Linux Netdev List <netdev@vger.kernel.org>, stable@kernel.org
To: Sam Ravnborg <sam@ravnborg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:59434 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750912AbYLASmh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2008 13:42:37 -0500
In-Reply-To: <20081201175225.GA1835@uranus.ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sam Ravnborg wrote:
> On Mon, Dec 01, 2008 at 05:15:42PM +0100, Oliver Hartkopp wrote:
>   
>>
>> Thanks to Kurt Van Dijck for pointing at this issue and for the review.
>>
>> Signed-Off-by: Oliver Hartkopp <oliver@hartkopp.net>
>> Acked-by: Kurt Van Dijck <kurt.van.dijck@eia.be>
>>     
>
> If Kurt tested this patch then he should
> be credited with a "Tested-by:" tag.
>
> I recall he did but I deleted the thread from my can mailbox.
>
> 	Sam
>   
Hi Sam,

i did some testing and posted the results of a first patch that went 
into the final direction.

In

https://lists.berlios.de/pipermail/socketcan-core/2008-December/002117.html

Kurt gave a "Reviewed-by:" and in a later mail in

https://lists.berlios.de/pipermail/socketcan-core/2008-December/002119.html

he wrote "my Acked-by: still stands" for the final patch.

So i choosed "Acked-by:".

As Kurt went that deep into the code that he pointed me to the right 
line and presented a first idea for a patch, an 'Acked-by:' for 
confirming the final patch looked like an appropriate credit to me.

Regards,
Oliver

