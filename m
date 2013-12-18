From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCHv3 net-next 0/7] pktgen IPsec support
Date: Wed, 18 Dec 2013 08:41:22 -0500
Message-ID: <52B1A602.2090903@mojatatu.com>
References: <1387094284-2901-1-git-send-email-fan.du@windriver.com> <52AEF4ED.4020504@mojatatu.com> <52AFB580.5060403@windriver.com> <52B05482.7030400@gmail.com> <52B0FEEB.70508@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net,
	steffen.klassert@secunet.com, hadi@cyberus.ca,
	netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:36367 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752673Ab3LRNlZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 08:41:25 -0500
Received: by mail-ie0-f181.google.com with SMTP id e14so10193158iej.40
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 05:41:24 -0800 (PST)
In-Reply-To: <52B0FEEB.70508@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/17/13 20:48, Fan Du wrote:
>
>> Maybe i missed something - receiver wasnt affected in the discussion.
>> It was only the sender.
>
> It's in this thread, see: 
> http://www.spinics.net/lists/netdev/msg260537.html
>

Ok, in that case please add my acked-by

> No, those information does not belong to pktgen at all.
>
> All we need is a 'spi' to point which SA to employ for the 
> transformation. The SA, either
> manually created temporally for pktgen test, or using existing 
> one(though with different
> tmpl info)will describe specific type(ESP/AH) or 
> mode(Transport/Tunnel) in use.
>


Fair enough.

cheers,
jamal
