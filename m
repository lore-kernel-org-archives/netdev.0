From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net 08/13] net/mlx5e: Implement ndo_tx_timeout callback
Date: Thu, 30 Jun 2016 15:15:14 +0000
Message-ID: <CO2PR11MB00884EE7E853CF8FEC58C4D897240@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1467297290-11443-1-git-send-email-saeedm@mellanox.com>
 <1467297290-11443-9-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Daniel Jurgens <danielj@mellanox.com>
To: Saeed Mahameed <saeedm@mellanox.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bbn0106.outbound.protection.outlook.com ([157.56.111.106]:8929
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751964AbcF3PPU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 11:15:20 -0400
In-Reply-To: <1467297290-11443-9-git-send-email-saeedm@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Add callback to handle TX timeouts.
> 
> Fixes: f62b8bb8f2d3 ('net/mlx5: Extend mlx5_core to support ConnectX-4 Ethernet functionality')

Not that I mind, but does implementing ndo_tx_timeout actually counts as a fix?
