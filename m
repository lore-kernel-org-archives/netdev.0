From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH] net: unix: non blocking recvmsg() should not return -EINTR
Date: Thu, 27 Mar 2014 08:49:01 -0400
Message-ID: <53341E3D.1010803@mojatatu.com>
References: <1395798147.12610.196.camel@edumazet-glaptop2.roam.corp.google.com>	<063D6719AE5E284EB5DD2968C1650D6D0F6E9790@AcuExch.aculab.com>	<87zjkd802t.fsf@sable.mobileactivedefense.com>	<1395847524.12610.208.camel@edumazet-glaptop2.roam.corp.google.com>	<87y4zw7ngi.fsf@sable.mobileactivedefense.com>	<87ha6k7jt7.fsf@sable.mobileactivedefense.com>	<063D6719AE5E284EB5DD2968C1650D6D0F6EA4FF@AcuExch.aculab.com> <87zjkb7r1q.fsf@sable.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:38214 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753781AbaC0MtE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 08:49:04 -0400
Received: by mail-ie0-f175.google.com with SMTP id to1so3366437ieb.20
        for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 05:49:03 -0700 (PDT)
In-Reply-To: <87zjkb7r1q.fsf@sable.mobileactivedefense.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/27/14 08:40, Rainer Weikusat wrote:
> David Laight <David.Laight@ACULAB.COM> writes:
>
> I'm find with any behaviour which does not restore the original 'lost
> wakeup' bug and considering that "it is a standard procedure to harras
> people who are so careless to contribute bug fixes to Linux until the
> cow comes home and they'd better be quiet about that!", as Mr Eric
> "/dev/null" Dumasomething explained, I certainly don't plan to turn this
> conviction of mine into a proper patch.

I think anything you say past this point nobody is listening.
You may actually have something of value to say but the passive
aggressiveness is going to bite your ass.

cheers,
jamal
