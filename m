From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 06/21] ARCNET: com20020: remove unneeded macros
Date: Fri, 24 Apr 2015 16:04:45 -0700
Message-ID: <1429916685.23327.32.camel@perches.com>
References: <1429896055-31680-1-git-send-email-m.grzeschik@pengutronix.de>
	 <1429896055-31680-7-git-send-email-m.grzeschik@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel@pengutronix.de
To: Michael Grzeschik <m.grzeschik@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429896055-31680-7-git-send-email-m.grzeschik@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-04-24 at 19:20 +0200, Michael Grzeschik wrote:
> The macros SET_SUBADR, ARCRESET, ARCRESET0, ACOMMAND, ASTATUS, AINTMASK
> and ADIAGSTATUS are unnecessary indirections to the use of registers.
> This patch removes them and improves the readability of the code.

This breaks compilation.

Please compile test your patches before sending them.
