From: David Miller <davem@davemloft.net>
Subject: Re: [Patch 2/2] mlx4: remove num_lro parameter
Date: Sun, 22 Aug 2010 21:45:35 -0700 (PDT)
Message-ID: <20100822.214535.91327106.davem@davemloft.net>
References: <20100818075530.5926.67960.sendpatchset@localhost.localdomain>
	<20100818075540.5926.9432.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	Ramkrishna.Vepa@exar.com, sgruszka@redhat.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53052
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752923Ab0HWEpS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 00:45:18 -0400
In-Reply-To: <20100818075540.5926.9432.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amerigo Wang <amwang@redhat.com>
Date: Wed, 18 Aug 2010 03:51:18 -0400

> 
> As suggested by David, this parameter can die, we can use ethtool
> to turn LRO on/off. Compile tests only.
> 
> Signed-off-by: WANG Cong <amwang@redhat.com>

Applied.
