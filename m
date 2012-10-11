From: David Miller <davem@davemloft.net>
Subject: Re: [STABLE REQUEST] add: e1000: fix lockdep splat in shutdown
 handler
Date: Thu, 11 Oct 2012 18:22:14 -0400 (EDT)
Message-ID: <20121011.182214.2229957213838024407.davem@davemloft.net>
References: <1349993385.24256.79.camel@gandalf.local.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, tglx@linutronix.de, stable@vger.kernel.org,
	jesse.brandeburg@intel.com, jeffrey.t.kirsher@intel.com
To: rostedt@goodmis.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40272 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932166Ab2JKWWQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 18:22:16 -0400
In-Reply-To: <1349993385.24256.79.camel@gandalf.local.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steven Rostedt <rostedt@goodmis.org>
Date: Thu, 11 Oct 2012 18:09:45 -0400

> Can you add this to the 3.2 stable tree.
> 
> commit 3a3847e007aae732d64d8fd1374126393e9879a3
> Author: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Date:   Wed Jan 4 20:23:33 2012 +0000
> 
>     e1000: fix lockdep splat in shutdown handler

Acked-by: David S. Miller <davem@davemloft.net>
