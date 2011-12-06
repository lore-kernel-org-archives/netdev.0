From: Michael Wang <wangyun@linux.vnet.ibm.com>
Subject: Re: Patch is wrong
Date: Tue, 06 Dec 2011 16:19:48 +0800
Message-ID: <4EDDD024.5000102@linux.vnet.ibm.com>
References: <4EDD8B8C.7000905@linux.vnet.ibm.com> <20111205.233937.1669740069700653317.davem@davemloft.net> <4EDDA413.1080106@linux.vnet.ibm.com> <20111206.002543.601828580754067320.davem@davemloft.net> <CAFeW=pZXgfNAy_f_HkgUjt+Rh7VwTXpkwiog1ki=fnDJ6_by4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linuxram@us.ibm.com, fbl@redhat.com, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com
To: Amos Kong <kongjianjun@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp07.in.ibm.com ([122.248.162.7]:41449 "EHLO
	e28smtp07.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932984Ab1LFIT6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 03:19:58 -0500
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <wangyun@linux.vnet.ibm.com>;
	Tue, 6 Dec 2011 13:49:55 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pB68JpDV3989622
	for <netdev@vger.kernel.org>; Tue, 6 Dec 2011 13:49:51 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pB68JoQu019079
	for <netdev@vger.kernel.org>; Tue, 6 Dec 2011 19:19:51 +1100
In-Reply-To: <CAFeW=pZXgfNAy_f_HkgUjt+Rh7VwTXpkwiog1ki=fnDJ6_by4g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/06/2011 04:11 PM, Amos Kong wrote:

> On Tue, Dec 6, 2011 at 1:25 PM, David Miller <davem@davemloft.net
> <mailto:davem@davemloft.net>> wrote:
> 
>     From: Michael Wang <wangyun@linux.vnet.ibm.com
>     <mailto:wangyun@linux.vnet.ibm.com>>
>     Date: Tue, 06 Dec 2011 13:11:47 +0800
> 
>     > I know it will cost you many works, but I still have to ask you to
>     > replace this patch, because this will become a mistake in Linux, which
>     > will make me sad each time I saw it on git log.
> 
>     It is simply not possible without screwing over every single person
>     who follows my tree.
> 
>     If I go in and pull out the change, then everyone who follows my
>     tree will have a corrupt tree.
> 
>     Sorry, mistakes happen, and once they are pushed out to GIT trees
>     used by lots of people we have to live with it.
> 
> 
> Send a patch to revert it and re-send a new one with right Author??
> Do you think it's meaningless ;-)
> 

Hi, Amos

Thanks for your suggestion, but I don't want to focus on it any more,
that will cause other's trouble.

So I will try to forgot it as soon as possible :)

Regards,
Michael Wang

>  
> 
>     --
>     To unsubscribe from this list: send the line "unsubscribe netdev" in
>     the body of a message to majordomo@vger.kernel.org
>     <mailto:majordomo@vger.kernel.org>
>     More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
