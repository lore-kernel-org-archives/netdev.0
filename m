From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: freescale: fec_main.c: Cleaning up
 missing null-terminate in conjunction with strncpy
Date: Mon, 15 Sep 2014 14:17:27 -0400 (EDT)
Message-ID: <20140915.141727.73988373928852130.davem@davemloft.net>
References: <1410715962-15986-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grant.likely@linaro.org, robh+dt@kernel.org, B38611@freescale.com,
	rmk+kernel@arm.linux.org.uk, fabio.estevam@freescale.com,
	frank.li@freescale.com, u.kleine-koenig@pengutronix.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org
To: rickard_strandqvist@spectrumdigital.se
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1410715962-15986-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Date: Sun, 14 Sep 2014 19:32:42 +0200

> Replacing strncpy with strlcpy to avoid strings that lacks null terminate.
> 
> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>

Applied.
