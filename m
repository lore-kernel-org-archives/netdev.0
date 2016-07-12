From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: nps_enet: Fix PCS reset
Date: Tue, 12 Jul 2016 13:59:19 -0700 (PDT)
Message-ID: <20160712.135919.89447461145040603.davem@davemloft.net>
References: <1468328471-8014-1-git-send-email-eladkan@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, abrodkin@synopsys.com,
	netdev@vger.kernel.org, noamca@mellanox.com
To: eladkan@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49050 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750776AbcGLU7a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 16:59:30 -0400
In-Reply-To: <1468328471-8014-1-git-send-email-eladkan@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Kanfi <eladkan@mellanox.com>
Date: Tue, 12 Jul 2016 16:01:11 +0300

> From: Noam Camus <noamca@mellanox.com>
> 
> During commit b54b8c2d6e3c
>  ("net: ezchip: adapt driver to little endian architecture")
>  adapting to little endian architecture,
>  zeroing of controller was left out.
> 
> Signed-off-by: Elad Kanfi <eladkan@mellanox.com>

Applied.
