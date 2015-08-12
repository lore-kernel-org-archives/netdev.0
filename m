From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv1 net-next 0/5] netlink: mmap: kernel panic and some
 issues
Date: Wed, 12 Aug 2015 16:38:19 -0700 (PDT)
Message-ID: <20150812.163819.620222685130362816.davem@davemloft.net>
References: <20150722131730.GA18037@gmail.com>
	<20150812082824.GA13385@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de
To: chamaken@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60710 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751887AbbHLXiU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 19:38:20 -0400
In-Reply-To: <20150812082824.GA13385@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ken-ichirou MATSUZAWA <chamaken@gmail.com>
Date: Wed, 12 Aug 2015 17:28:24 +0900

> It would be better if someone else is working on this.
> Or could you help me out? It's a tough work for me.

If you are fixing a panic, you must show that panic message
and describe in detail the exact sequence of events and state
that lead to that crash.  And then also exactly why your fix
takes care of the problem, and why it is the proper way to
approach the issue.

As-is, your commit message and this top-level introductory
posting are way too terse and I myself can't even figure out
what exactly the purpose of this series is, and what bug it
is precisely fixing.
