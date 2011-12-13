From: David Miller <davem@davemloft.net>
Subject: Re: pull request: batman-adv 2011-12-12
Date: Mon, 12 Dec 2011 19:28:21 -0500 (EST)
Message-ID: <20111212.192821.886469661461010981.davem@davemloft.net>
References: <1323689516-24427-1-git-send-email-lindner_marek@yahoo.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: lindner_marek@yahoo.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41634 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753690Ab1LMA30 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2011 19:29:26 -0500
In-Reply-To: <1323689516-24427-1-git-send-email-lindner_marek@yahoo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>
Date: Mon, 12 Dec 2011 19:31:44 +0800

> here comes the next batch I'd like to get the pulled into net-next-2.6/3.3.
> We have a couple of minor fixes for unregister_netdevice(), compat flags,
> return value checks and a readme update. Plus the regression fix from Dan
> that addresses a bug introduced with the previous batch. Security 
> researcher Paul Kot checked our kernelland / user space communication and
> found a subtle bug which would make batman-adv write to memory locations
> it should not write to. However, he did not find a way to exploit this
> bug, therefore we classified it as "non-critical". Please let us know if
> that is not ok with you.

All pulled into net-next, thanks.
