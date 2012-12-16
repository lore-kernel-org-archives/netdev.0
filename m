From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] can: sja1000: fix compilation on x86
Date: Sat, 15 Dec 2012 17:16:00 -0800 (PST)
Message-ID: <20121215.171600.1207782952199175480.davem@davemloft.net>
References: <1355523912-1977-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	rdunlap@infradead.org, andreas@gaisler.com
To: mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1355523912-1977-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Fri, 14 Dec 2012 23:25:12 +0100

> Since commit:
> 04df251 can: sja1000: Make sja1000_of_platform selectable and compilable on SPARC
> the driver can be activated on non powerpc platform like x86 or sparc. Without
> this patch the driver fails to compile on platform that don't define NO_IRQ,
> like x86.
> 
> Reported-by: Randy Dunlap <rdunlap@infradead.org>
> Cc: Andreas Larsson <andreas@gaisler.com>
> Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>

Applied.
