From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND] net: lpc_eth: Driver cleanup
Date: Tue, 19 Jun 2012 00:28:17 -0700 (PDT)
Message-ID: <20120619.002817.595558964141813189.davem@davemloft.net>
References: <1340050482-22666-1-git-send-email-stigge@antcom.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kevin.wells@nxp.com,
	srinivas.bakki@nxp.com, aletes.xgr@gmail.com,
	linux-arm-kernel@lists.infradead.org
To: stigge@antcom.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1340050482-22666-1-git-send-email-stigge@antcom.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roland Stigge <stigge@antcom.de>
Date: Mon, 18 Jun 2012 22:14:42 +0200

> This patch removes some nowadays superfluous definitions (one unused define and
> an obsolete function forward declaration) and corrects a netdev_err() to
> netdev_dbg().
> 
> Signed-off-by: Roland Stigge <stigge@antcom.de>
> Signed-off-by: Alexandre Pereira da Silva <aletes.xgr@gmail.com>

Applied.
