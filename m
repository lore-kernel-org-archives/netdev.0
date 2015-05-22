From: "Vittorio G (VittGam)" <linuxbugs@vittgam.net>
Subject: Re: [PATCH net] ipv4: Avoid crashing in =?UTF-8?Q?ip=5Ferror?=
Date: Fri, 22 May 2015 21:17:43 +0200
Message-ID: <2c75dd4007d921b495da1df62e69bc02@vittgam.net>
References: <87zj4x6iiz.fsf_-_@x220.int.ebiederm.org>
 <20150522.142447.1048811620866120127.davem@davemloft.net>
 <379cd5bb2c3e9b3041c41d758c833ff0@vittgam.net>
 <20150522.150542.1824059270184099624.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ebiederm@xmission.com>, <netdev@vger.kernel.org>,
	<security@kernel.org>, <greg@kroah.com>, <luto@amacapital.net>,
	<w@1wt.eu>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server1.vittgam.net ([213.239.197.142]:61374 "EHLO
	mail.vittgam.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757168AbbEVTSP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 15:18:15 -0400
In-Reply-To: <20150522.150542.1824059270184099624.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Il 22.05.2015 21:05 David Miller ha scritto:
> From: "Vittorio G (VittGam)" <linuxbugs@vittgam.net>
> Date: Fri, 22 May 2015 20:48:38 +0200
>
>> I think this should also be backported up to Linux mainline 3.10,
>> since
>> the original commit that introduced the bug first appeared in 3.6.
>
> Ummm, that's what "queued up for -stable" means.  It means that I'll
> submit it to -stable for all active -stable series.

Uh, sorry. I'm not (yet) entirely familiar with the words used here. ;)
