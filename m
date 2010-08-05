From: Arnd Hannemann <arnd@arndnet.de>
Subject: Re: GIT: net-*2.6 rebased...
Date: Thu, 05 Aug 2010 16:45:28 +0200
Message-ID: <4C5ACE88.2070704@arndnet.de>
References: <20100804.162141.15218463.davem@davemloft.net>
 <4C5A6EFE.7040703@arndnet.de> <20100805.014637.13722703.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	sfr@canb.auug.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-2.ms.rz.RWTH-Aachen.DE ([134.130.7.73]:40212 "EHLO
	mta-2.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933244Ab0HEOpx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Aug 2010 10:45:53 -0400
In-reply-to: <20100805.014637.13722703.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 05.08.2010 10:46, schrieb David Miller:
> From: Arnd Hannemann <arnd@arndnet.de> Date: Thu, 05 Aug 2010
> 09:57:50 +0200
>
>> if I try to fetch from net-next-2.6, I get: fatal: The remote end
>> hung up unexpectedly
>>
>> if I try to clone net-2.6: (e.g. git clone
>> git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git
>>
>> I get lots of errors reading the tags "does not point to a valid
>> object!" and then: remote: error: Could not read
>> 3cfc2c42c1cbc8e238bb9c0612c0df4565e3a8b4 remote: fatal: Failed to
>> traverse parents of commit
>> 7aaaaa1e44b2a4047dfe05f304a5090eb995cf44 remote: aborting due to
>> possible repository corruption on the remote side. fatal: early
>> EOF fatal: index-pack failed
>
> I fixed the alternates file but it will take some time for the fix to
> propagate from master.kernel.org
>
> Let me know if it doesn't work even after an hour or so.

It works now, for both net-next-2.6 and net-2.6.

Thanks,
Arnd

