From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: clear RTF_EXPIRES when call ip6_rt_copy
Date: Thu, 19 Dec 2013 01:37:42 +0100
Message-ID: <20131219003742.GA14429@order.stressinduktion.org>
References: <CAJFZqHxawisUbHGZY8mjGHy8035X6TQ7FNzc20vtS5j1jdZYGA@mail.gmail.com> <20131217070231.GA11970@order.stressinduktion.org> <52B00150.3070002@cn.fujitsu.com> <20131217134823.GC18396@order.stressinduktion.org> <52B0F0C4.1010803@cn.fujitsu.com> <CAJFZqHywaN4k64zd-fcw7=DD+6iNX_Psuwi2QKH_GX-_04TVSg@mail.gmail.com> <52B103DE.7090604@cn.fujitsu.com> <CAJFZqHxB8PscqXnX9oxpHf8zFyW1hyCZVZTn_=DoKebN3X2ZGA@mail.gmail.com> <20131218062000.GC27460@order.stressinduktion.org> <52B15F64.4070303@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: RongQing Li <roy.qing.li@gmail.com>, netdev@vger.kernel.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:37967 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752990Ab3LSAhn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 19:37:43 -0500
Content-Disposition: inline
In-Reply-To: <52B15F64.4070303@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 18, 2013 at 04:40:04PM +0800, Gao feng wrote:
> Seem like user can add expired route by manually. rtmsg_to_fib6_config set the
> cfg->fc_expires. I'm ok if you want to set from always now.

Roy, can you send an updated patch now?

Thanks,

  Hannes
