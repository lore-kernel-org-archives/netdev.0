From: David Miller <davem@davemloft.net>
Subject: Re: Commit "ipconfig wait for carrier" makes boot hang for 2 mins
 if no carrier
Date: Wed, 05 Sep 2012 13:01:58 -0400 (EDT)
Message-ID: <20120905.130158.897788930198410991.davem@davemloft.net>
References: <OFFA3AC1B1.08FC3AAD-ONC1257A70.00266EDC-C1257A70.0026E8BC@transmode.se>
	<50470DAC.8030009@neli.hopto.org>
	<OF70CDBF7F.EFE301C2-ONC1257A70.002F0D3F-C1257A70.003055BF@transmode.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: micha@neli.hopto.org, netdev@vger.kernel.org
To: joakim.tjernlund@transmode.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42710 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750800Ab2IERCA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2012 13:02:00 -0400
In-Reply-To: <OF70CDBF7F.EFE301C2-ONC1257A70.002F0D3F-C1257A70.003055BF@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Date: Wed, 5 Sep 2012 10:47:56 +0200

> Please adjust the 2 min wait to nfsroot= only and keep the old way for ip=

Sorry, this is not happening, I fully support the change in the tree
as-is and will not modify it in the way you request.

You'll have to accomodate this situation in some other local way.
