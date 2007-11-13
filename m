From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NET] netfilter : xt_time should not assume CONFIG_KTIME_SCALAR
Date: Tue, 13 Nov 2007 16:38:23 +0100
Message-ID: <4739C4EF.3050705@trash.net>
References: <47398ADD.2030509@cosmosbay.com> <20071113.035019.268404275.davem@davemloft.net> <4739938E.6010905@trash.net> <47399D34.40306@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49027 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755269AbXKMPjH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 10:39:07 -0500
In-Reply-To: <47399D34.40306@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Patrick McHardy a =E9crit :
>> David Miller wrote:
>>>
>>> Patrick, this is very clearly a correct bug fix, so I'm
>>> going to apply this directly.
>>
>>
>> Thanks, thats obviously correct. Still, I would prefer if
>> people would CC netfilter-devel and myself, it has become
>> a bad habit lately especially to skip netfilter-devel.
>>
>>
> Sorry for forgeting netfilter-devel, I'll try to remember for next ti=
me...


Thanks Eric. I missed that I actually was CCed because greylisting
took a bit longer to let it through :)
