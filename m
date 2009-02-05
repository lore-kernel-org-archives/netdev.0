From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH 2.6.29] cxgb3 - Fix lro switch
Date: Wed, 04 Feb 2009 16:35:49 -0800
Message-ID: <498A3465.80405@chelsio.com>
References: <20090205002547.26126.47373.stgit@speedy5> <20090204.163250.127196315.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com, kxie@chelsio.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761306AbZBEAgW@vger.kernel.org>
In-Reply-To: <20090204.163250.127196315.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Divy Le Ray <divy@chelsio.com>
> Date: Wed, 04 Feb 2009 16:25:47 -0800
>
>   
>> The LRO switch is always set to 1 in the rx processing loop.
>> It breaks the accelerated iSCSI receive traffic.
>> Fix its computation.
>>
>> Signed-off-by: Divy Le Ray <divy@chelsio.com>
>>     
>
> Applied, thank you.
>
> Could you slightly reformat your Subject lines for patches?  Please
> use something like "cxgb3: $(description)" instead of the "cxgb3 -
> $(description)" you're using now.
>
> It'll be one less thing I need to edit when applying your
> patches :-)
>   

Sorry about that. I'll use this format from now on.

cheers,
Divy
