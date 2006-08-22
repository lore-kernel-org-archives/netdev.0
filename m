From: Andrew Morton <akpm@osdl.org>
Subject: Re: [take12 0/3] kevent: Generic event handling mechanism.
Date: Tue, 22 Aug 2006 16:35:35 -0700
Message-ID: <20060822163535.ddea8797.akpm@osdl.org>
References: <1156281182.2476.63.camel@entropy>
	<20060822143747.68acaf99.rdunlap@xenotime.net>
	<20060822150144.058d9052.akpm@osdl.org>
	<20060822.151747.56047759.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: rdunlap@xenotime.net, nmiell@comcast.net, johnpol@2ka.mipt.ru,
	linux-kernel@vger.kernel.org, drepper@redhat.com,
	netdev@vger.kernel.org, zach.brown@oracle.com, hch@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:3539 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932262AbWHVXgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2006 19:36:11 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060822.151747.56047759.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 22 Aug 2006 15:17:47 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Andrew Morton <akpm@osdl.org>
> Date: Tue, 22 Aug 2006 15:01:44 -0700
> 
> > If there _is_ something wrong with kqueue then let us identify those
> > weaknesses and then diverge.
> 
> Evgeniy already enumerated this, both on his web site and in the
> current thread.

<googles, spends a few minutes clicking around on
http://tservice.net.ru/~s0mbre/, fails.  Looks in changelogs, also fails>

Best I can find is
http://tservice.net.ru/~s0mbre/blog/devel/kevent/index.html, and that's
doesn't cover these things.

At some stage we're going to need to tell Linus (for example) what we've
done and why we did it.  I don't know how to do that.

