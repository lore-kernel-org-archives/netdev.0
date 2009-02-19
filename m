From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH 2.6.30] cxgb3: Add support for PCI ID 0x35.
Date: Wed, 18 Feb 2009 18:25:13 -0800
Message-ID: <499CC309.3080305@chelsio.com>
References: <20090216044615.24884.9331.stgit@speedy5> <20090218.174835.12982157.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:12162 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752621AbZBSC1N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 21:27:13 -0500
In-Reply-To: <20090218.174835.12982157.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Divy Le Ray <divy@chelsio.com>
> Date: Sun, 15 Feb 2009 20:46:15 -0800
>
>   
>> Add support for adapters with a PCI id equal to 0x35.
>>
>> Signed-off-by: Divy Le Ray <divy@chelsio.com>
>>     
>
> Adding new IDs is something we can do in net-2.6, so I'm
> going to add this patch there.
>
> Let me know if you don't want me to do that, or if there
> is some dependency with net-next-2.6 that I'm not seeing.
>   

Hi Dave,

Applying it against net-2.6 is all good.

Cheers,
Divy
