From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: add NETLINK_NO_ENOBUFS socket flag
Date: Tue, 24 Mar 2009 16:38:09 -0700 (PDT)
Message-ID: <20090324.163809.142202089.davem@davemloft.net>
References: <20090323141858.6808.50788.stgit@Decadence>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47839
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753333AbZCXXiV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 19:38:21 -0400
In-Reply-To: <20090323141858.6808.50788.stgit@Decadence>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Mon, 23 Mar 2009 15:18:59 +0100

> This patch adds the NETLINK_NO_ENOBUFS socket flag. This flag can
> be used by unicast and broadcast listeners to avoid receiving
> ENOBUFS errors.
...
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

Applied, thanks Pablo.
