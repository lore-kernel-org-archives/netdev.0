From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] NET: Add TCP connection abort IOCTL
Date: Thu, 29 Mar 2007 18:09:28 -0700
Message-ID: <460C6348.5030904@osdl.org>
References: <20070327214754.GA11677@dag-work>	<20070327.153025.45876618.davem@davemloft.net>	<46d726f90703290756k1894b0aal8df85d46d8c2a25e@mail.gmail.com> <20070329.114139.55510589.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: predrag.hodoba@gmail.com, dagriego@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:45021 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934202AbXC3BJe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Mar 2007 21:09:34 -0400
In-Reply-To: <20070329.114139.55510589.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: "Predrag Hodoba" <predrag.hodoba@gmail.com>
> Date: Thu, 29 Mar 2007 16:56:22 +0200
>
>   
>> Need for such an API is to a degree indicated in the Carrier Grade Linux
>> requirements by The Linux Foundation (former OSDL).
>>     
>
> Something being in the CGL specification is to me exactly a great
> reason NOT to add it.  That specification is so full of garbage it's
> unbelievable.
>
> Thanks, you've given me one more reason not to even remotely consider
> adding this feature.
>   
Agreed, CGL is a vendor driven group that has always wanted to replicate
proprietary misfeatures onto Linux.  There is a real requirement to
provide high availability but there should be no requirement to implement
the solution in the same crap way as legacy Unix.
