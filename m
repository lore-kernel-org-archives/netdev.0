From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] pfkey: fix warning
Date: Tue, 01 Mar 2011 22:52:01 -0800 (PST)
Message-ID: <20110301.225201.71118501.davem@davemloft.net>
References: <20110301223913.2caf53c3@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42382
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751853Ab1CBGvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 01:51:23 -0500
In-Reply-To: <20110301223913.2caf53c3@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 1 Mar 2011 22:39:13 -0800

> If CONFIG_NET_KEY_MIGRATE is not defined the arguments of
> pfkey_migrate stub do not match causing warning.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks!
