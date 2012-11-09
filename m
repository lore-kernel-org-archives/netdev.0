From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: add knob to send unsolicited ND on link-layer
 address change
Date: Fri, 09 Nov 2012 16:22:59 -0500 (EST)
Message-ID: <20121109.162259.141861970162047674.davem@davemloft.net>
References: <20121107024620.GD26398@order.stressinduktion.org>
	<20121109130141.GA31099@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38419 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755761Ab2KIVXB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 16:23:01 -0500
In-Reply-To: <20121109130141.GA31099@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Fri, 9 Nov 2012 14:01:41 +0100

> David, if you intend to merge this patch, could you please remove the empty
> line I accidently added in the addrconf_sysctl_table, directly following
> .proc_handler? As usual, I noticed it just after sending the patch.

I intend to eventually apply this to net-next, and I'll take care
of the empty line when I do so, thanks.
