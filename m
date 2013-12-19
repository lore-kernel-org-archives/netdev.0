From: RongQing Li <roy.qing.li@gmail.com>
Subject: Re: [PATCH] ipv6: clear RTF_EXPIRES when call ip6_rt_copy
Date: Thu, 19 Dec 2013 08:47:14 +0800
Message-ID: <CAJFZqHw3OpW0Lwg0yxbmpXDOAW3gegBfs+JnohFh4Z3P73=Phg@mail.gmail.com>
References: <CAJFZqHxawisUbHGZY8mjGHy8035X6TQ7FNzc20vtS5j1jdZYGA@mail.gmail.com>
	<20131217070231.GA11970@order.stressinduktion.org>
	<52B00150.3070002@cn.fujitsu.com>
	<20131217134823.GC18396@order.stressinduktion.org>
	<52B0F0C4.1010803@cn.fujitsu.com>
	<CAJFZqHywaN4k64zd-fcw7=DD+6iNX_Psuwi2QKH_GX-_04TVSg@mail.gmail.com>
	<52B103DE.7090604@cn.fujitsu.com>
	<CAJFZqHxB8PscqXnX9oxpHf8zFyW1hyCZVZTn_=DoKebN3X2ZGA@mail.gmail.com>
	<20131218062000.GC27460@order.stressinduktion.org>
	<52B15F64.4070303@cn.fujitsu.com>
	<20131219003742.GA14429@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Gao feng <gaofeng@cn.fujitsu.com>,
	RongQing Li <roy.qing.li@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:61688 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751249Ab3LSArP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 19:47:15 -0500
Received: by mail-vb0-f46.google.com with SMTP id w20so246280vbb.5
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 16:47:15 -0800 (PST)
In-Reply-To: <20131219003742.GA14429@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 19, 2013 at 8:37 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On Wed, Dec 18, 2013 at 04:40:04PM +0800, Gao feng wrote:
>> Seem like user can add expired route by manually. rtmsg_to_fib6_config set the
>> cfg->fc_expires. I'm ok if you want to set from always now.
>
> Roy, can you send an updated patch now?
>
> Thanks,
>
>   Hannes
>

Ok, Thanks

-Roy
