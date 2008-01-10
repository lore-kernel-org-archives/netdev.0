From: Ming-Ching Tiew <mingching.tiew@redtone.com>
Subject: Re: [Bugme-new]  [Bug 9719] New: when a system is configured as a
 bridge, and at the same time configured to have multipath weighted route,
 with one leg goes thru NAT and another without NAT, the nat path will intermittently
 get packets leaking out using internal IP without being SNAT-ted
Date: Fri, 11 Jan 2008 01:25:49 +0800
Message-ID: <4786551D.8010700@redtone.com>
References: <bug-9719-10286@http.bugzilla.kernel.org/> <20080109152813.83fb8168.akpm@linux-foundation.org> <4786187E.3090000@redtone.com> <47864892.9010605@redtone.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: Ming-Ching Tiew <mingching.tiew@redtone.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.cnx.com.my ([202.46.113.21]:2635 "EHLO mail.cnx.com.my"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753599AbYAJE0E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jan 2008 23:26:04 -0500
In-Reply-To: <47864892.9010605@redtone.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ming-Ching Tiew wrote:
> Ming-Ching Tiew wrote:
>>
>> What I meant was that it failed on both the kernel versions I tested. 
>> I am afraid it  is a problem which exists all a long. Perhaps it has 
>> been broken quite sometime already. I need to go back to try some 
>> older kernel version and see if I could repeat the problem.
>
> OK based on the I repeat the problem, so far I could not find such 
> misbehaviour on kernel 2.6.18. I will do more tests to make it more 
> conclusive.
>

Sorry for jumping the gun. Kernel 2.6.18 has the same problem too.
I think from now on, I will refrain from early posting until conclusive 
results.



