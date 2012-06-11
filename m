From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] net: lpc_eth: Replace WARN() trace with simple
 pr_warn()
Date: Mon, 11 Jun 2012 02:03:52 -0700 (PDT)
Message-ID: <20120611.020352.1962768244524496467.davem@davemloft.net>
References: <1339401793-12258-1-git-send-email-stigge@antcom.de>
	<1339403108.6001.1697.camel@edumazet-glaptop>
	<4FD5AE1D.9030807@antcom.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kevin.wells@nxp.com,
	srinivas.bakki@nxp.com, aletes.xgr@gmail.com,
	linux-arm-kernel@lists.infradead.org
To: stigge@antcom.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4FD5AE1D.9030807@antcom.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roland Stigge <stigge@antcom.de>
Date: Mon, 11 Jun 2012 10:36:45 +0200

> But maybe this is wrong. Can you please give me a hint how the net
> subsystem makes sure that this doesn't happen under normal circumstances?

Well if you are asking this question then you didn't read my feedback,
because I explained exactly what prevents this.
