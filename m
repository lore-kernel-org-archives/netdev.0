From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 5/5] net: sh_eth: add support for VLAN tag
 filtering
Date: Thu, 16 Feb 2012 17:09:12 -0500 (EST)
Message-ID: <20120216.170912.1114653613945489169.davem@davemloft.net>
References: <4F3C7E1A.4040806@renesas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com
To: yoshihiro.shimoda.uh@renesas.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43903 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754259Ab2BPWJQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2012 17:09:16 -0500
In-Reply-To: <4F3C7E1A.4040806@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Date: Thu, 16 Feb 2012 12:55:06 +0900

> Some controllers have TSU. It can register one VLAN tag, and it can
> filter other VLAN tag by hardware.
> If vlan_rx_add_vid() is called twice or more, the driver will disable
> the filtering.
> 
> Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>

Applied.
