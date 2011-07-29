From: synapse <synapse@hippy.csoma.elte.hu>
Subject: Re: PROBLEM: BUG (NULL ptr dereference in ipv4_dst_check)
Date: Fri, 29 Jul 2011 16:44:59 +0200
Message-ID: <4E32C76B.5010700@hippy.csoma.elte.hu>
References: <1311946421.2843.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>	 <4E32C302.8050304@hippy.csoma.elte.hu>	 <1311950184.2843.22.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>	 <20110729.073910.59762029845942660.davem@davemloft.net> <1311950488.2843.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:49289 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751491Ab1G2OpQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jul 2011 10:45:16 -0400
In-Reply-To: <1311950488.2843.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/29/11 16:41, Eric Dumazet wrote:
> Le vendredi 29 juillet 2011 =C3=A0 07:39 -0700, David Miller a =C3=A9=
crit :
>> From: Eric Dumazet<eric.dumazet@gmail.com>
>> Date: Fri, 29 Jul 2011 16:36:24 +0200
>>
>>> Hmm, I'll take a look, but check_peer_redir() seems suspicious at f=
irst
>>> glance.
>> I take full responsibility for any bugs you discover in it :-)
>
> ;)
>
> Bug origin is commit f39925dbde7788cfb96419c0f092b086aa325c0f
> ipv4: Cache learned redirect information in inetpeer.
>
> I'll cook a patch ASAP
>
wow that was QUICK :)

When you're done I'll check it ASAP

Gergely Kalman
