From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dsa: Handle non-bridge master change
Date: Wed, 25 Mar 2015 14:07:17 -0400 (EDT)
Message-ID: <20150325.140717.458262147377513231.davem@davemloft.net>
References: <1427296117-1805-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, andrew@lunn.ch, sfeldma@gmail.com,
	netdev@vger.kernel.org
To: linux@roeck-us.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48432 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753297AbbCYSHT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 14:07:19 -0400
In-Reply-To: <1427296117-1805-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guenter Roeck <linux@roeck-us.net>
Date: Wed, 25 Mar 2015 08:08:37 -0700

> Master change notifications may occur other than when joining or
> leaving a bridge, for example when being added to or removed from
> a bond or Open vSwitch. In that case, do nothing instead of asking
> the switch driver to remove a port from a bridge that it didn't join.
> 
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Applied.
