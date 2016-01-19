From: Damien Riegel <damien.riegel@savoirfairelinux.com>
Subject: Re: [PATCH v4 1/3] can: sja1000: of: add per-compatible init hook
Date: Tue, 19 Jan 2016 15:08:39 -0500
Message-ID: <20160119200839.GA12067@localhost>
References: <1452685566-27431-1-git-send-email-mkl@pengutronix.de>
 <1452685566-27431-2-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1452685566-27431-2-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Marc,

On Wed, Jan 13, 2016 at 12:46:04PM +0100, Marc Kleine-Budde wrote:
> From: Damien Riegel <damien.riegel@savoirfairelinux.com>
> 
> This commit adds the capability to allocate and init private data
> embedded in the sja1000_priv structure on a per-compatible basis. The
> device node is passed as a parameter of the init callback to allow
> parsing of custom device tree properties.
> 
> Signed-off-by: Damien Riegel <damien.riegel@savoirfairelinux.com>
> Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>

I see that you haven't taken this serie in your tree. What is its
status? Are there still some issues that need to be addressed?

Thanks,
Damien
