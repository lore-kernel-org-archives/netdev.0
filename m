From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH v2 net-next] sockopt: Change getsockopt() of SO_BINDTODEVICE
 to return an interface name
Date: Mon, 26 Nov 2012 10:10:18 -0500
Message-ID: <50B3865A.6090402@hp.com>
References: <50A6A8FB.3050901@hp.com> <20121120.135842.249477087130415954.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: xemul@parallels.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:43695 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754901Ab2KZPKY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 10:10:24 -0500
In-Reply-To: <20121120.135842.249477087130415954.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/20/2012 01:58 PM, David Miller wrote:
>> v2: Added seqlock protection while copying device name.
>>
>> Signed-off-by: Brian Haley <brian.haley@hp.com>
> 
> Brian I was going to apply this, but something about how you email
> patches results in them being corrupted.
> 
> Go to:
> 
> http://patchwork.ozlabs.org/patch/199732/
> 
> Click on Download "mbox", and try to apply that to the net-next tree
> to see what I mean.

I'll take a look why that was wrapping and send a v3, been away...

-Brian
