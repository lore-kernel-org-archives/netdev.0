From: David Miller <davem@davemloft.net>
Subject: Re: pull request: batman-adv 2012-08-23
Date: Fri, 24 Aug 2012 11:46:01 -0400 (EDT)
Message-ID: <20120824.114601.1698041558649925346.davem@davemloft.net>
References: <1345727427-20805-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: ordex@autistici.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53714 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759645Ab2HXPqD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 11:46:03 -0400
In-Reply-To: <1345727427-20805-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>
Date: Thu, 23 Aug 2012 15:10:09 +0200

> this is our set of changes intended for net-next/linux-3.7.
> It is mostly composed by style fixes and cleanups. Other than that you have a
> patch introducing a new table in debugfs (backbone gateways table for the Bridge
> Loop Avoidance) and a new mechanism for the TranslationTable component. The
> latter allows mesh nodes to immediately detect new clients joining the network,
> without waiting for any periodic advertisement.

Pulled, thanks Antonio.
