From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mdio_bus: Fix MDIO bus scanning in __mdiobus_register()
Date: Sun, 01 May 2016 19:49:45 -0400 (EDT)
Message-ID: <20160501.194945.1926401275113473949.davem@davemloft.net>
References: <1461892155-10524-1-git-send-email-marex@denx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arnd@arndb.de,
	dinguyen@opensource.altera.com, f.fainelli@gmail.com,
	sergei.shtylyov@cogentembedded.com
To: marex@denx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53305 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752436AbcEAXts (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 May 2016 19:49:48 -0400
In-Reply-To: <1461892155-10524-1-git-send-email-marex@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please respin this with the checkpatch errors fixed.

I don't have any opinion about the conditional parenthesis, so
don't worry about that.
