From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] drivers/net/phy/micrel_phy: Add support for
 new PHYs
Date: Mon, 28 Jan 2013 18:42:33 -0500 (EST)
Message-ID: <20130128.184233.1844461901341919423.davem@davemloft.net>
References: <FD9AD8C5375B924CABC56D982DB3A802079D346F@EXMB1.micrel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ping.Doong@Micrel.Com,
	bhutchings@solarflare.com
To: David.Choi@Micrel.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49396 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755540Ab3A1Xmf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2013 18:42:35 -0500
In-Reply-To: <FD9AD8C5375B924CABC56D982DB3A802079D346F@EXMB1.micrel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Choi, David" <David.Choi@Micrel.Com>
Date: Thu, 24 Jan 2013 00:05:15 +0000

> From: David J. Choi <david.choi@micrel.com>
> 
> Summary of changes:
> .Newly added phys 
> 	-KSZ8081/KSZ8091, which has some phy ids.
> 	-KSZ8061
> 	-KSZ9031, which is Gigabit phy.
> 	-KSZ886X, which has a switch function.
> 	-KSZ8031, which has a same phy ids with KSZ8021.
>  
> Signed-off-by: David J. Choi <david.choi@micrel.com>

Applied, thanks.
