From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCHv2 2/3] phylib: move to dynamic allocation of struct mii_bus
Date: Wed, 1 Oct 2008 22:11:55 -0500
Message-ID: <A7731131-A355-4B1D-93D0-1AE47DAF0661@freescale.com>
References: <20081002014142.GC26575@xi.wantstofly.org>
Mime-Version: 1.0 (Apple Message framework v928.1)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Byron Bradley <byron.bbradley@gmail.com>,
	Tim Ellis <tim.ellis@mac.com>, Imre Kaloz <kaloz@openwrt.org>,
	Nicolas Pitre <nico@cam.org>, Dirk Teurlings <dirk@upexia.nl>,
	Peter van Valderen <p.v.valderen@gmail.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:58713 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751590AbYJBDMR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 23:12:17 -0400
In-Reply-To: <20081002014142.GC26575@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Oct 1, 2008, at 20:41, Lennert Buytenhek wrote:

> This patch introduces mdiobus_alloc() and mdiobus_free(), and
> makes all mdio bus drivers use these functions to allocate their
> struct mii_bus'es dynamically.
>
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

Acked-by: Andy Fleming <afleming@freescale.com>


