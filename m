From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next 0/6] kcm: Kernel Connection Multiplexor (KCM)
Date: Tue, 24 Nov 2015 17:25:47 -0500 (EST)
Message-ID: <20151124.172547.672210919260359472.davem@redhat.com>
References: <20151124205537.GC23215@breakpoint.cc>
	<CALx6S36oFH9=Px=pptZurWgS1MtFbhOE=FeK0jZmNBk3fU7tSg@mail.gmail.com>
	<20151124222242.GD23215@breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, hannes@stressinduktion.org,
	netdev@vger.kernel.org, kernel-team@fb.com, davejwatson@fb.com,
	alexei.starovoitov@gmail.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43599 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754307AbbKXWZt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Nov 2015 17:25:49 -0500
In-Reply-To: <20151124222242.GD23215@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Tue, 24 Nov 2015 23:22:42 +0100

> Yes, I get that point, but I maintain that KCM is a strange workaround
> for bad userspace design.

I fundamentally disagree with you.

And even if I didn't, I would be remiss to completely dismiss the
difficulty in changing existing protocols and existing large scale
implementations of them.  If we can facilitate them somehow then
I see nothing wrong with that.

Neither you nor Hannes have made a strong enough argument for me
to consider Tom's work not suitable for upstream.

Have you even looked at the example userspace use case he referenced
and considered the constraints under which it operates?  I seriously
doubt you did.
