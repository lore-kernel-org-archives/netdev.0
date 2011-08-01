From: synapse <synapse@hippy.csoma.elte.hu>
Subject: Re: PROBLEM: BUG (NULL ptr dereference in ipv4_dst_check)
Date: Mon, 01 Aug 2011 17:25:59 +0200
Message-ID: <4E36C587.4020803@hippy.csoma.elte.hu>
References: <1311950488.2843.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>	 <4E32C76B.5010700@hippy.csoma.elte.hu>	 <1311952306.2843.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>	 <20110729.081902.300678107767426313.davem@davemloft.net>	 <1311954208.2843.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>	 <1312002053.2873.41.camel@edumazet-laptop>	 <4E366A8F.201@hippy.csoma.elte.hu> <1312190145.2719.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:34395 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752920Ab1HAP0E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Aug 2011 11:26:04 -0400
In-Reply-To: <1312190145.2719.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/01/11 11:15, Eric Dumazet wrote:
> Le lundi 01 ao=C3=BBt 2011 =C3=A0 10:57 +0200, synapse a =C3=A9crit :
>> Hello
>>
>> Sorry, I wasn't home on the weekend. Exactly to which tree should I
>> apply this?
>> It doesn't apply cleanly to 3.0.0. Am I missing something?
>>
> Could you try latest linux tree ?
>
> We first validate patches on current tree, then backport them if need=
ed
> to previous kernels.
>
> Thanks
>
deployed, we'll see if it works out :)

Gergely Kalman
