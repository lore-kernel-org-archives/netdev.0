From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6: NLM_F_* flag support for route creation/changing
 when using netlink.
Date: Thu, 27 Oct 2011 03:06:58 -0400 (EDT)
Message-ID: <20111027.030658.1922451477684539766.davem@davemloft.net>
References: <82C9FC7ED59434458AD4E09AFF2DE230BF099B@FIESEXC006.nsn-intra.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: matti.vaittinen.ext@nsn.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35907 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754376Ab1J0HHF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2011 03:07:05 -0400
In-Reply-To: <82C9FC7ED59434458AD4E09AFF2DE230BF099B@FIESEXC006.nsn-intra.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Vaittinen, Matti (EXT-Other - FI/Oulu)" <matti.vaittinen.ext@nsn.com>
Date: Thu, 27 Oct 2011 09:26:05 +0300

> 
> Will requiring NLM_F_CREATE break lots of existing userspace software?

I can almost guarenetee that since we haven't been requiring this,
it will break almost everything.

> --- linux-3.1-rc4.orig/net/ipv6/ip6_fib.c	2011-10-26
> 13:15:17.000000000 +0300

Your patch is also severely mangled by your email client and is
thus unusable for us.

Please read Documentation/email-clients.txt before submitting any
more patches.

Thank you.
