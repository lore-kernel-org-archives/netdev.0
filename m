From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] Add temperature reading and registers dump to
 mv88e6171
Date: Sun, 16 Nov 2014 15:48:24 -0500 (EST)
Message-ID: <20141116.154824.1141288177115607505.davem@davemloft.net>
References: <1416086694-15790-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux@roeck-us.net
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38378 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750743AbaKPUsa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2014 15:48:30 -0500
In-Reply-To: <1416086694-15790-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Sat, 15 Nov 2014 22:24:50 +0100

> These patches centralize the temperature sensor reading code, and then
> make use of it with the mv88e6171 which has a compatible
> sensor. Additionally, support is added for reading the mv88e6171 via
> ethtool.

Series applied to net-next, thanks.
