From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 2/2] div64_64: common code
Date: Tue, 6 Mar 2007 16:04:30 -0800
Message-ID: <20070306160430.d3cf47a8.akpm@linux-foundation.org>
References: <200703061042.l26AgS0U019809@shell0.pdx.osdl.net>
	<20070306.101140.101595874.davem@davemloft.net>
	<20070306143206.f8c29714.akpm@linux-foundation.org>
	<20070306.152140.105428124.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	chris@zankel.net, geert@linux-m68k.org, jdike@addtoit.com,
	ralf@linux-mips.org, rmk@arm.linux.org.uk, zippel@linux-m68k.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:38138 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030758AbXCGAIC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 19:08:02 -0500
In-Reply-To: <20070306.152140.105428124.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 06 Mar 2007 15:21:40 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Tue, 6 Mar 2007 14:32:06 -0800
> 
> > ho hum, I didn't know that, so we missed rc2-mm2.
> > 
> > Could I have symlinks in /pub/scm/linux/kernel/git/davem/ to net-latest and
> > sparc-latest please?
> 
> When we are in a merge window, I have only one tree for sparc
> and networking.
> 
> But when we're in RC mode, I've got multiple trees, one each
> for bug fixes and one for stuff which will get submitted in
> the next merge window.
> 
> When Linus pulls in the bug fixes, I rebase the merge window trees so
> that all the fixes get integrated to the merge tree and I can resolve
> any conflicts, if any.
> 
> So, which one(s) do you want? :-)

The merge-window things, generally.

I assume from the above that the merge-window tree doesn't contain the
paterial in the bugfixes tree?  If so, I guess I'd need both.  If not, the
merge-window tree should contain everything?

I dunno - you know your trees better than I.  The bottom line is I want
everything you've got, and it'd be nice to fix this problem where I don't
know that a new tree has been opened up, so I miss it - how can we do this?
