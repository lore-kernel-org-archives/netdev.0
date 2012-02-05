From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Net: caifdev is never used in
 net/caif/caif_dev.c::transmit() - remove it.
Date: Sun, 05 Feb 2012 17:54:01 -0500 (EST)
Message-ID: <20120205.175401.1607753113306832696.davem@davemloft.net>
References: <alpine.LNX.2.00.1202052348450.32529@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sjur.brandeland@stericsson.com, remi.denis-courmont@nokia.com,
	sakari.ailus@nokia.com
To: jj@chaosbits.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1202052348450.32529@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Juhl <jj@chaosbits.net>
Date: Sun, 5 Feb 2012 23:50:46 +0100 (CET)

> Signed-off-by: Jesper Juhl <jj@chaosbits.net>

Applied.

I changed the subject prefix to "caif: " and the one for your previous
patch to "decnet: "  Please don't put that "Net, " thing there.
