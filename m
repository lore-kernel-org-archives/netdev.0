From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] can: dev: fix nlmsg size calculation in can_get_size()
Date: Mon, 07 Oct 2013 15:56:10 -0400 (EDT)
Message-ID: <20131007.155610.1175248330541668920.davem@davemloft.net>
References: <1381001117-19624-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	kernel@pengutronix.de, wg@grandegger.com
To: mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1381001117-19624-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Sat,  5 Oct 2013 21:25:17 +0200

> This patch fixes the calculation of the nlmsg size, by adding the missing
> nla_total_size().
> 
> Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>

Applied and queued up for -stable, thanks.
