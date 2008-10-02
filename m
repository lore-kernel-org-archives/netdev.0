From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCHv2 3/3] phylib: give mdio buses a device tree presence
Date: Wed, 1 Oct 2008 22:12:17 -0500
Message-ID: <91BF54FA-4C0E-47D0-80F0-69833B0C29EC@freescale.com>
References: <20081002014201.GD26575@xi.wantstofly.org>
Mime-Version: 1.0 (Apple Message framework v928.1)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Byron Bradley <byron.bbradley@gmail.com>,
	Tim Ellis <tim.ellis@mac.com>, Imre Kaloz <kaloz@openwrt.org>,
	Nicolas Pitre <nico@cam.org>, Dirk Teurlings <dirk@upexia.nl>,
	Peter van Valderen <p.v.valderen@gmail.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:63384 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751846AbYJBDMa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 23:12:30 -0400
In-Reply-To: <20081002014201.GD26575@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Oct 1, 2008, at 20:42, Lennert Buytenhek wrote:

> Introduce the mdio_bus class, and give each 'struct mii_bus' its own
> 'struct device', so that mii_bus objects are represented in the device
> tree and can be found by querying the device tree.
>
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

Acked-by: Andy Fleming <afleming@freescale.com>

