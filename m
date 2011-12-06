From: Michael Wang <wangyun@linux.vnet.ibm.com>
Subject: Re: Patch is wrong
Date: Tue, 06 Dec 2011 13:11:47 +0800
Message-ID: <4EDDA413.1080106@linux.vnet.ibm.com>
References: <4EDD8B8C.7000905@linux.vnet.ibm.com> <20111205.233937.1669740069700653317.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxram@us.ibm.com, fbl@redhat.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp03.in.ibm.com ([122.248.162.3]:36582 "EHLO
	e28smtp03.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750783Ab1LFFL5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 00:11:57 -0500
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <wangyun@linux.vnet.ibm.com>;
	Tue, 6 Dec 2011 10:41:54 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pB65BoKF1515730
	for <netdev@vger.kernel.org>; Tue, 6 Dec 2011 10:41:50 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pB65BnB6009028
	for <netdev@vger.kernel.org>; Tue, 6 Dec 2011 16:11:49 +1100
In-Reply-To: <20111205.233937.1669740069700653317.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/06/2011 12:39 PM, David Miller wrote:

> From: Michael Wang <wangyun@linux.vnet.ibm.com>
> Date: Tue, 06 Dec 2011 11:27:08 +0800
> 
>> I am the author of this patch, and Jeff only change 0, 1 to false and
>> true, now he become the author.
> 
> Take it up with Jeff, I pulled the change from his GIT tree and that's
> where the authorship information came from.
> 

Hi, David

Jeff know what happened, he promised to add my and Flavio's
signed-off-by in the pre-mail.

It's easy to see from the mail that who is the author, and I have reply
just after Jeff's patch send out to you, I add my signed-off-by and
From, but no one care.

I know you are all experts and have lots of patches in community, you
won't care such a small patch's author, but this is very important for
me because this is my first patch, it's stand for my passion and will to
join the community.

I know it will cost you many works, but I still have to ask you to
replace this patch, because this will become a mistake in Linux, which
will make me sad each time I saw it on git log.

Thanks & Best regards
Michael Wang

> Unfortunately, it cannot be fixed as it's already pushed out to my
> tree.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
