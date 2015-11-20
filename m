From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: Fix vxlan removal
Date: Fri, 20 Nov 2015 10:58:53 -0500 (EST)
Message-ID: <20151120.105853.2181510807773696174.davem@davemloft.net>
References: <1447927011-3282-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com, jbenc@redhat.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32769 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760087AbbKTP6z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2015 10:58:55 -0500
In-Reply-To: <1447927011-3282-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Thu, 19 Nov 2015 11:56:51 +0200

> Commmit ac7eccd4d48fc "bnx2x: track vxlan port count" contains a bug -
> Instead of achieving the required goal, vxlan configuration would not
> be removed since we're decrementing the port instead of the counter.
> 
> CC: Jiri Benc <jbenc@redhat.com>
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>

Applied, thank you.
