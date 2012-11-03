From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vxlan: allow a user to set TTL value
Date: Sat, 03 Nov 2012 15:25:06 -0400 (EDT)
Message-ID: <20121103.152506.1189836496822209310.davem@davemloft.net>
References: <1351628836-23094-1-git-send-email-bernat@luffy.cx>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: bernat@luffy.cx
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58059 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752478Ab2KCTZH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2012 15:25:07 -0400
In-Reply-To: <1351628836-23094-1-git-send-email-bernat@luffy.cx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vincent Bernat <bernat@luffy.cx>
Date: Tue, 30 Oct 2012 21:27:16 +0100

> "ip link add ... type vxlan ... ttl X" allows a user to set the TTL
> used by a VXLAN for encapsulation. The provided value was ignored by
> vxlan module and the default value of 1 was used when encapsulating
> multicast packets.
> 
> Signed-off-by: Vincent Bernat <bernat@luffy.cx>

Applied net-next.
