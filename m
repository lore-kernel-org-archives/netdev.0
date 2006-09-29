From: "Wong Edison" <hswong3i@gmail.com>
Subject: Re: [PATCH] tcp-lp: prevent chance for oops
Date: Sat, 30 Sep 2006 03:27:00 +0800
Message-ID: <3feffd230609291226n673d9aa4s2f16fbacd34cfc48@mail.gmail.com>
References: <3feffd230609280343o1975ee70o8a55acf3e5d4769e@mail.gmail.com>
	 <20060928.144029.32722435.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0102.google.com ([64.233.162.206]:4338 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S1751351AbWI2T1C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 15:27:02 -0400
Received: by nz-out-0102.google.com with SMTP id n1so451588nzf
        for <netdev@vger.kernel.org>; Fri, 29 Sep 2006 12:27:01 -0700 (PDT)
To: "David Miller" <davem@davemloft.net>
In-Reply-To: <20060928.144029.32722435.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I do this since i have a sourceforge homepage for it. I update the CVS
version there, test, and then submit to netdev. As I sync code in both
side, this $Id$ is keeped.

May you just let it be? I think it will let my maintenance become more simple...

On 9/29/06, David Miller <davem@davemloft.net> wrote:
> From: "Wong Edison" <hswong3i@gmail.com>
> Date: Thu, 28 Sep 2006 18:43:58 +0800
>
> >   *
> > - * Version: $Id: tcp_lp.c,v 1.24 2006/09/05 20:22:53 hswong3i Exp $
> > + * Version: $Id: tcp_lp.c,v 1.25 2006/09/22 20:50:27 hswong3i Exp $
>
> BTW, I'm deleting this line from the source file in the tree
> because every patch you send doesn't apply cleanly because
> your patch is against a different string on this line and we
> don't use $Id$ tags in the kernel sources anyways.
>
