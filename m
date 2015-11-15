From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/6] net: dsa: mv88e6060: cleanup and fix setup
Date: Sun, 15 Nov 2015 13:20:38 -0500 (EST)
Message-ID: <20151115.132038.1689858006374228784.davem@davemloft.net>
References: <5642126D.9040105@baylibre.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	f.fainelli@gmail.com, andrew@lunn.ch, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com
To: narmstrong@baylibre.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51500 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751095AbbKOSUk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Nov 2015 13:20:40 -0500
In-Reply-To: <5642126D.9040105@baylibre.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Armstrong <narmstrong@baylibre.com>
Date: Tue, 10 Nov 2015 16:51:09 +0100

> This patchset introduces some fixes and a registers addressing cleanup for
> the mv88e6060 DSA driver.
> 
> The first patch removes the poll_link as mv88e6xxx.
> The 3 following patches fixes the setup in regards of the datasheet.
> The 2 last patches introduces a clean header and replaces all magic values.
> 
> v2: cleanup InitReady patch, add missing Acked-by and fix header copyright notice

Series applied, thanks.
