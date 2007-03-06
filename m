From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/2] div64_64: common code
Date: Tue, 06 Mar 2007 15:21:40 -0800 (PST)
Message-ID: <20070306.152140.105428124.davem@davemloft.net>
References: <200703061042.l26AgS0U019809@shell0.pdx.osdl.net>
	<20070306.101140.101595874.davem@davemloft.net>
	<20070306143206.f8c29714.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	chris@zankel.net, geert@linux-m68k.org, jdike@addtoit.com,
	ralf@linux-mips.org, rmk@arm.linux.org.uk, zippel@linux-m68k.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38416
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030702AbXCFXVn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 18:21:43 -0500
In-Reply-To: <20070306143206.f8c29714.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>
Date: Tue, 6 Mar 2007 14:32:06 -0800

> ho hum, I didn't know that, so we missed rc2-mm2.
> 
> Could I have symlinks in /pub/scm/linux/kernel/git/davem/ to net-latest and
> sparc-latest please?

When we are in a merge window, I have only one tree for sparc
and networking.

But when we're in RC mode, I've got multiple trees, one each
for bug fixes and one for stuff which will get submitted in
the next merge window.

When Linus pulls in the bug fixes, I rebase the merge window trees so
that all the fixes get integrated to the merge tree and I can resolve
any conflicts, if any.

So, which one(s) do you want? :-)
