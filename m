From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-2.6.22-rc7] xfrm beet interfamily support
Date: Thu, 19 Jul 2007 21:43:07 +0200
Message-ID: <469FBECB.6080204@trash.net>
References: <200707161506.47915.joakim.koskela@hiit.fi> <200707191708.58863.joakim.koskela@hiit.fi> <469F7952.207@trash.net> <200707192054.38945.joakim.koskela@hiit.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: joakim.koskela@hiit.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41466 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753324AbXGSTqh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 15:46:37 -0400
In-Reply-To: <200707192054.38945.joakim.koskela@hiit.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joakim Koskela wrote:
> On Thursday 19 July 2007 17:46:42 Patrick McHardy wrote:
>   
>> And these two? Also look like bugfixes ..
>>
>>     
>
> Well yes if we're using interfamily anywhere. D'you think they deserve a patch 
> for themselves?
>   


Yes, that looks worth it. And it will help reduce the size of your
patch and make it easier reviewable.


