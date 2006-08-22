From: David Miller <davem@davemloft.net>
Subject: Re: [take12 0/3] kevent: Generic event handling mechanism.
Date: Tue, 22 Aug 2006 01:23:41 -0700 (PDT)
Message-ID: <20060822.012341.57449506.davem@davemloft.net>
References: <1156230051.8055.27.camel@entropy>
	<20060822072448.GA5126@2ka.mipt.ru>
	<1156234672.8055.51.camel@entropy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, linux-kernel@vger.kernel.org,
	drepper@redhat.com, akpm@osdl.org, netdev@vger.kernel.org,
	zach.brown@oracle.com, hch@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:697
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932132AbWHVIXh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Aug 2006 04:23:37 -0400
To: nmiell@comcast.net
In-Reply-To: <1156234672.8055.51.camel@entropy>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicholas Miell <nmiell@comcast.net>
Date: Tue, 22 Aug 2006 01:17:52 -0700

> Is any of this documented anywhere? I'd think that any new userspace
> interfaces should have man pages explaining their use and some example
> code before getting merged into the kernel to shake out any interface
> problems.

Get real.

Nobody made this requirement for things like splice() et al.

I think people are being mostly very unreasonable in the
demands they are making upon Evgeniy.  It will only serve
to discourage the one person who is doing work to solve
these problems.

