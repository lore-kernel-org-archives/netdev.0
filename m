From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: about : [NET]: Replace CONFIG_NET_DEBUG with sysctl.
Date: Fri, 09 Mar 2007 08:15:28 -0800
Message-ID: <45F18820.5090205@linux-foundation.org>
References: <20070308205305.582324346@linux-foundation.org>	<20070308.204209.69409441.davem@davemloft.net>	<45F0FFE7.1080304@cosmosbay.com> <20070308.223748.74750176.davem@davemloft.net> <45F105E6.7040608@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:38452 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767356AbXCIQPr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Mar 2007 11:15:47 -0500
In-Reply-To: <45F105E6.7040608@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> David Miller a =E9crit :
>> From: Eric Dumazet <dada1@cosmosbay.com>
>> Date: Fri, 09 Mar 2007 07:34:15 +0100
>>
>>> I gently ask that any new sysctl is '__read_mostly' tagged.
>>
>> People are lazy because you are so gifted at finding this
>> stuff :-)
>
> I seeeeeee ;)
>
> BTW I missed the patch on netdev, is it just me or netdev have proble=
ms ?
>
My bad, forgot the CC in the patch cleanout yesterday
