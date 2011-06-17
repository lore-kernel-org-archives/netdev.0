From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 001/001] vlan: don't call ndo_vlan_rx_register on
 hardware that doesn't have vlan support
Date: Fri, 17 Jun 2011 00:13:10 -0400 (EDT)
Message-ID: <20110617.001310.887138223551857478.davem@davemloft.net>
References: <BANLkTimBm8rFF41RzAN6vk3o6SLy6cfZDQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: a.reversat@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51968 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750772Ab1FQENN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 00:13:13 -0400
In-Reply-To: <BANLkTimBm8rFF41RzAN6vk3o6SLy6cfZDQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antoine Reversat <a.reversat@gmail.com>
Date: Thu, 16 Jun 2011 16:47:13 -0400

> This patch removes the call to ndo_vlan_rx_register if the underlying
> device doesn't have hardware support for VLAN.
> Signed-off-by: Antoine Reversat <a.reversat@gmail.com>

Applied, thanks.
