From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] Altera TSE with no PHY
Date: Sun, 05 Oct 2014 21:40:17 -0400 (EDT)
Message-ID: <20141005.214017.2039528585409013032.davem@davemloft.net>
References: <1412359741-8423-1-git-send-email-walter@vanguardiasur.com.ar>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tobias.klauser@gmail.com,
	vbridgers2013@gmail.com, f.fainelli@gmail.com,
	nios2-dev@lists.rocketboards.org, ezequiel@vanguardiasur.com.ar,
	guido@vanguardiasur.com.ar
To: walter@vanguardiasur.com.ar
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56679 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752160AbaJFBkT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2014 21:40:19 -0400
In-Reply-To: <1412359741-8423-1-git-send-email-walter@vanguardiasur.com.ar>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Walter Lozano <walter@vanguardiasur.com.ar>
Date: Fri,  3 Oct 2014 15:08:59 -0300

> In some scenarios there is no PHY chip present, for example in optical links.
> This serie of patches moves PHY get addr and MDIO create to a new function and
> avoids PHY and MDIO probing in these cases.

Series applied, thanks Walter.
