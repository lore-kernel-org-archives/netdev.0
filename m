From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/28] net: ethernet: stmicro: stmmac: drop owner
 assignment from platform_drivers
Date: Mon, 22 Dec 2014 16:31:07 -0500 (EST)
Message-ID: <20141222.163107.1023158393448021294.davem@davemloft.net>
References: <1419196495-9626-1-git-send-email-wsa@the-dreams.de>
	<1419196495-9626-11-git-send-email-wsa@the-dreams.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, peppe.cavallaro@st.com,
	netdev@vger.kernel.org
To: wsa@the-dreams.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1419196495-9626-11-git-send-email-wsa@the-dreams.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wolfram Sang <wsa@the-dreams.de>
Date: Sun, 21 Dec 2014 22:14:31 +0100

> This platform_driver does not need to set an owner, it will be populated by the
> driver core.
> 
> Signed-off-by: Wolfram Sang <wsa@the-dreams.de>

Applied, thanks.
