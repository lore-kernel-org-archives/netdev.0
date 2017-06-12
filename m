From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] sh_eth: add support for changing MTU
Date: Mon, 12 Jun 2017 09:58:13 -0400 (EDT)
Message-ID: <20170612.095813.58100051008915326.davem@davemloft.net>
References: <20170612083903.1584-1-niklas.soderlund+renesas@ragnatech.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org
To: niklas.soderlund+renesas@ragnatech.se
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20170612083903.1584-1-niklas.soderlund+renesas@ragnatech.se>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>
Date: Mon, 12 Jun 2017 10:39:03 +0200

> The hardware supports the MTU to be changed and the driver it self is
> somewhat prepared to support this. This patch hooks up the callbacks to
> be able to change the MTU from user-space.
> 
> Signed-off-by: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>
> Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied to net-next, thanks.
