From: Roland Dreier <roland@kernel.org>
Subject: Re: linux-next: just chaeking correctness of the infiniband tree
Date: Thu, 20 Jun 2013 22:51:47 -0700
Message-ID: <CAG4TOxNp0h5i2tGwYxVQeV8Yk=QrvtCAp-xTxRfF2-Am44tJ9A@mail.gmail.com>
References: <20130621100928.36a0ccf45e310f02a4dff53a@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:32862 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422753Ab3FUFwJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jun 2013 01:52:09 -0400
In-Reply-To: <20130621100928.36a0ccf45e310f02a4dff53a@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 20, 2013 at 5:09 PM, Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> I noticed that the infiniband tree is now based on the net-next tree.  I
> assume that is deliberate?  I do have to question how much testing that
> tree has had since it is now based on a tree that Dave only released in
> the last 24 hours ...

That is intentional since there is work coming that relies on net-next
prerequisites.

The tree hasn't had much testing, but pushing it out a few weeks
before the merge window is the way it gets testing.
