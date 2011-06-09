From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: generate link local address for GRE
 tunnel
Date: Wed, 08 Jun 2011 17:06:31 -0700 (PDT)
Message-ID: <20110608.170631.1499221777656109768.davem@davemloft.net>
References: <20110608134430.112c2591@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48419 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750880Ab1FIAGc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2011 20:06:32 -0400
In-Reply-To: <20110608134430.112c2591@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 8 Jun 2011 13:44:30 -0700

> Use same logic as SIT tunnel to handle link local address
> for GRE tunnel. OSPFv3 requires link-local address to function.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks Stephen.
