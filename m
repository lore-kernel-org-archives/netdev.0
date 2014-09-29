From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3 0/2] add Qualcomm QCA7000 ethernet driver
Date: Mon, 29 Sep 2014 00:24:45 -0400 (EDT)
Message-ID: <20140929.002445.1795924959329545473.davem@davemloft.net>
References: <1411770081-20995-1-git-send-email-stefan.wahren@i2se.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	f.fainelli@gmail.com, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
To: stefan.wahren@i2se.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50427 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750844AbaI2EYr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 00:24:47 -0400
In-Reply-To: <1411770081-20995-1-git-send-email-stefan.wahren@i2se.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Wahren <stefan.wahren@i2se.com>
Date: Fri, 26 Sep 2014 22:21:19 +0000

> This patch series adds support for the Qualcomm QCA7000 Homeplug GreenPHY.
> The QCA7000 is serial-to-powerline bridge with two interfaces: UART and SPI.
> These patches handles only the last one, with an Ethernet over SPI protocol
> driver.

Applied to net-next, thanks.
