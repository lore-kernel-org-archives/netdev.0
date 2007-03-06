From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 2/2] div64_64: common code
Date: Tue, 6 Mar 2007 14:32:06 -0800
Message-ID: <20070306143206.f8c29714.akpm@linux-foundation.org>
References: <200703061042.l26AgS0U019809@shell0.pdx.osdl.net>
	<20070306.101140.101595874.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	chris@zankel.net, geert@linux-m68k.org, jdike@addtoit.com,
	ralf@linux-mips.org, rmk@arm.linux.org.uk, zippel@linux-m68k.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:34046 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030383AbXCFWfn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 17:35:43 -0500
In-Reply-To: <20070306.101140.101595874.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 06 Mar 2007 10:11:40 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: akpm@linux-foundation.org
> Date: Tue, 06 Mar 2007 02:42:28 -0800
> 
> > From: Stephen Hemminger <shemminger@linux-foundation.org>
> > 
> > Implement div64_64(): 64-bit by 64-bit division.  Needed by networking (at
> > least).
> 
> This patch, with the types.h fixes of your's, is already in my
> net-2.6.22 GIT tree if you'd like to start pulling from there
> Andrew.

ho hum, I didn't know that, so we missed rc2-mm2.

Could I have symlinks in /pub/scm/linux/kernel/git/davem/ to net-latest and
sparc-latest please?

