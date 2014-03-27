From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH] net: unix: non blocking recvmsg() should not return -EINTR
Date: Thu, 27 Mar 2014 13:02:12 +0000
Message-ID: <87ppl7ztez.fsf@sable.mobileactivedefense.com>
References: <1395798147.12610.196.camel@edumazet-glaptop2.roam.corp.google.com>
	<063D6719AE5E284EB5DD2968C1650D6D0F6E9790@AcuExch.aculab.com>
	<87zjkd802t.fsf@sable.mobileactivedefense.com>
	<1395847524.12610.208.camel@edumazet-glaptop2.roam.corp.google.com>
	<87y4zw7ngi.fsf@sable.mobileactivedefense.com>
	<87ha6k7jt7.fsf@sable.mobileactivedefense.com>
	<063D6719AE5E284EB5DD2968C1650D6D0F6EA4FF@AcuExch.aculab.com>
	<87zjkb7r1q.fsf@sable.mobileactivedefense.com>
	<53341E3D.1010803@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@ACULAB.COM>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tiger.mobileactivedefense.com ([217.174.251.109]:51649 "EHLO
	tiger.mobileactivedefense.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752124AbaC0NC0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 09:02:26 -0400
In-Reply-To: <53341E3D.1010803@mojatatu.com> (Jamal Hadi Salim's message of
	"Thu, 27 Mar 2014 08:49:01 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jamal Hadi Salim <jhs@mojatatu.com> writes:
> On 03/27/14 08:40, Rainer Weikusat wrote:
>> David Laight <David.Laight@ACULAB.COM> writes:
>>
>> I'm find with any behaviour which does not restore the original 'lost
>> wakeup' bug and considering that "it is a standard procedure to harras
>> people who are so careless to contribute bug fixes to Linux until the
>> cow comes home and they'd better be quiet about that!", as Mr Eric
>> "/dev/null" Dumasomething explained, I certainly don't plan to turn this
>> conviction of mine into a proper patch.
>
> I think anything you say past this point nobody is listening.

Why would I care if someone like you 'listens' to me?
