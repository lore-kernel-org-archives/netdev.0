From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH] drivers: net: cpsw: Add support for fixed-link PHY
Date: Wed, 4 Nov 2015 20:55:09 +0530
Message-ID: <563A2355.7090100@ti.com>
References: <2251323.UEGYDRRlj7@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>
To: Markus Brunner <systemprogrammierung.brunner@gmail.com>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:53640 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932303AbbKDPZq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Nov 2015 10:25:46 -0500
In-Reply-To: <2251323.UEGYDRRlj7@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 04 November 2015 02:39 AM, Markus Brunner wrote:
> Add support for a fixed-link devicetree sub-node in case the the 
> cpsw MAC is directly connected to a non-mdio PHY/device. 
> 
> Signed-off-by: Markus Brunner <systemprogrammierung.brunner@gmail.com>

Looks good to me.

Acked-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
