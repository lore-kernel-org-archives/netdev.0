From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH stable 3.10.y 0/3] gso/gro forwarding changeset
Date: Tue, 25 Feb 2014 16:59:45 -0500 (EST)
Message-ID: <20140225.165945.1272928606573948770.davem@davemloft.net>
References: <1393061419-4892-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58117 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750941AbaBYV7r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Feb 2014 16:59:47 -0500
In-Reply-To: <1393061419-4892-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Sat, 22 Feb 2014 10:30:16 +0100

> 3.10 does not aggregate ~DF packets via GRO.  However, as
> Marcelo Leitner pointed out to me we can still encounter GSO packets in
> fwd path in virtual environments where we receive GSO packet eg. via virtio.
> 
> Let me know if there are problems.

All of your backports queued up and submitted to -stable, thanks for doing
this work!
