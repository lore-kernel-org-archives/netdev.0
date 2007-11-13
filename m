From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [NET] netfilter : xt_time should not assume CONFIG_KTIME_SCALAR
Date: Tue, 13 Nov 2007 13:48:52 +0100
Message-ID: <47399D34.40306@cosmosbay.com>
References: <47398ADD.2030509@cosmosbay.com> <20071113.035019.268404275.davem@davemloft.net> <4739938E.6010905@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp23.orange.fr ([193.252.22.126]:45626 "EHLO smtp23.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752200AbXKMNe7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 08:34:59 -0500
Received: from smtp23.orange.fr (mwinf2303 [10.232.4.25])
	by mwinf2325.orange.fr (SMTP Server) with ESMTP id E08F11C022B9
	for <netdev@vger.kernel.org>; Tue, 13 Nov 2007 13:49:37 +0100 (CET)
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf2303.orange.fr (SMTP Server) with ESMTP id 785681C0009A
	for <netdev@vger.kernel.org>; Tue, 13 Nov 2007 13:48:55 +0100 (CET)
In-Reply-To: <4739938E.6010905@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy a =E9crit :
> David Miller wrote:
>> From: Eric Dumazet <dada1@cosmosbay.com>
>> Date: Tue, 13 Nov 2007 12:30:37 +0100
>>
>>> It is not correct to assume one can get nsec from a ktime directly=20
>>> by using .tv64 field.
>>>
>>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>>
>> Patrick, this is very clearly a correct bug fix, so I'm
>> going to apply this directly.
>
>
> Thanks, thats obviously correct. Still, I would prefer if
> people would CC netfilter-devel and myself, it has become
> a bad habit lately especially to skip netfilter-devel.
>
>
Sorry for forgeting netfilter-devel, I'll try to remember for next time=
=2E..

Thank you




