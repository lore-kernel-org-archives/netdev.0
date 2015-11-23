From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/2] DSA: GPIO to reset switches
Date: Mon, 23 Nov 2015 11:53:34 -0500 (EST)
Message-ID: <20151123.115334.984221736473425935.davem@davemloft.net>
References: <1447988184-9562-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, preid@electromag.com.au,
	narmstrong@baylibre.com, f.fainelli@gmail.com
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53812 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754278AbbKWQxj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 11:53:39 -0500
In-Reply-To: <1447988184-9562-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Fri, 20 Nov 2015 03:56:22 +0100

> These two patches add support for using a GPIO to hard reset a switch
> during reset.
> 
> v2:
> 
> Thanks to a clue from Neil Armstrong, i figured out how to convert the
> gpio into a gpiod, while keeping the ACTIVE_LOW flag, so simplifiying
> the set/reset code.
> 
> I have not included the Tested-by: from Phil Reid, since i made a lot
> of changes.

Series applied, thanks Andrew.
