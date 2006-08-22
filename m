From: David Miller <davem@davemloft.net>
Subject: Re: [take12 0/3] kevent: Generic event handling mechanism.
Date: Tue, 22 Aug 2006 14:25:00 -0700 (PDT)
Message-ID: <20060822.142500.11271092.davem@davemloft.net>
References: <1156276823.2476.22.camel@entropy>
	<20060822.133606.48392664.davem@davemloft.net>
	<1156281220.2476.65.camel@entropy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, johnpol@2ka.mipt.ru,
	linux-kernel@vger.kernel.org, drepper@redhat.com, akpm@osdl.org,
	netdev@vger.kernel.org, zach.brown@oracle.com, hch@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:49380
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751300AbWHVVYo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Aug 2006 17:24:44 -0400
To: nmiell@comcast.net
In-Reply-To: <1156281220.2476.65.camel@entropy>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicholas Miell <nmiell@comcast.net>
Date: Tue, 22 Aug 2006 14:13:40 -0700

> And how is the quality of the work to be judged if the work isn't
> commented, documented and explained, especially the userland-visible
> parts that *cannot* *ever* *be* *changed* *or* *removed* once they're in
> a stable kernel release?

Are you even willing to look at the collection of example applications
Evgeniy wrote against this API?

That is the true test of a set of interfaces, what happens when you
try to actually use them in real programs.

Everything else is fluff, including standards and "documentation".

He even bothered to benchmark things, and post assosciated graphs and
performance analysis during the course of development.
