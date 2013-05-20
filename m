From: Peter =?iso-8859-15?q?H=FCwe?= <PeterHuewe@gmx.de>
Subject: Re: [PATCH] net/can/mcp251x: Use module_spi_driver to register driver
Date: Mon, 20 May 2013 22:17:29 +0200
Message-ID: <201305202217.29983.PeterHuewe@gmx.de>
References: <1369079399-6031-1-git-send-email-peterhuewe@gmx.de> <519A7F3B.1000105@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Wolfgang Grandegger <wg@grandegger.com>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Marc Kleine-Budde" <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <519A7F3B.1000105@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Montag, 20. Mai 2013, 21:53:31 schrieb Marc Kleine-Budde:
> On 05/20/2013 09:49 PM, Peter Huewe wrote:
> > Removing some boilerplate by using module_spi_driver instead of calling
> > register and unregister in the otherwise empty init/exit functions
> > 
> > Signed-off-by: Peter Huewe <peterhuewe@gmx.de>
> 
> A similar patch [1] by Lars-Peter Clausen hit mainline in v3.10-rc1.
> 
> thanks, Marc
> 
> [1] 01b8807 can: mcp251x: Use module_spi_driver


Thanks for noticing!
I was unfortunately working on a stale tree - sorry for the noise.

Thanks,
Peter
