From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH 1/3] phylib: allow incremental scanning of an mii bus
Date: Mon, 15 Sep 2008 17:33:56 -0500
Message-ID: <4CEE2275-95FC-456B-A9F9-14BE79CBD681@freescale.com>
References: <1220448012-20347-1-git-send-email-buytenh@wantstofly.org> <1220448012-20347-2-git-send-email-buytenh@wantstofly.org>
Mime-Version: 1.0 (Apple Message framework v928.1)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:48213 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753207AbYIOWeI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2008 18:34:08 -0400
In-Reply-To: <1220448012-20347-2-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sep 3, 2008, at 08:20, Lennert Buytenhek wrote:

> This patch splits the bus scanning code in mdiobus_register() off
> into a separate function, and makes this function available for
> calling from external code.  This allows incrementally scanning an
> mii bus, e.g. as information about which addresses are 'safe' to
> scan becomes available.
>
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

Acked-by: Andy Fleming <afleming@freescale.com>

