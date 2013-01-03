From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: add empty br_mdb_init() and br_mdb_uninit()
 definitions.
Date: Thu, 03 Jan 2013 03:35:34 -0800 (PST)
Message-ID: <20130103.033534.794090934751410920.davem@davemloft.net>
References: <1357212643-1324-1-git-send-email-ramirose@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevic@redhat.com
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51008 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752162Ab3ACLfh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2013 06:35:37 -0500
In-Reply-To: <1357212643-1324-1-git-send-email-ramirose@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <ramirose@gmail.com>
Date: Thu,  3 Jan 2013 13:30:43 +0200

> This patch adds empty br_mdb_init() and br_mdb_uninit() definitions in
> br_private.h to avoid build failure when CONFIG_BRIDGE_IGMP_SNOOPING is not set.
> These methods were moved from br_multicast.c to br_netlink.c by 
> commit 3ec8e9f085bcaef0de1077f555c2c5102c223390
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Applied, thanks Rami.
