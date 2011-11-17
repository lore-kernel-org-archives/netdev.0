From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 1/3 v2] team: Do not hold rcu_read_lock when
 running netlink cmds
Date: Wed, 16 Nov 2011 20:36:16 -0500 (EST)
Message-ID: <20111116.203616.878729314151558843.davem@davemloft.net>
References: <1321477749-1877-2-git-send-email-jpirko@redhat.com>
	<1321478244.3274.5.camel@edumazet-laptop>
	<20111116215554.GB9631@minipsycho>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	andy@greyhouse.net, fbl@redhat.com, jzupka@redhat.com,
	ivecera@redhat.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51847 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754803Ab1KQBgW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 20:36:22 -0500
In-Reply-To: <20111116215554.GB9631@minipsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Wed, 16 Nov 2011 22:55:54 +0100

> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied.
