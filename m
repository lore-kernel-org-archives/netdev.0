From: Jason Cooper <jason@lakedaemon.net>
Subject: Re: [PATCH 3/3] mvebu: defconfig: Enable the mv88E6171 switch
 driver
Date: Thu, 6 Nov 2014 22:32:01 -0500
Message-ID: <20141107033201.GF3698@titan.lakedaemon.net>
References: <1415214121-29286-1-git-send-email-andrew@lunn.ch>
 <1415214121-29286-4-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux ARM <linux-arm-kernel@lists.infradead.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	tawfik@marvell.com, maxime.ripard@free-electrons.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mho-02-ewr.mailhop.org ([204.13.248.72]:24678 "EHLO
	mho-02-ewr.mailhop.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751305AbaKGDcN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 22:32:13 -0500
Content-Disposition: inline
In-Reply-To: <1415214121-29286-4-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 05, 2014 at 08:02:01PM +0100, Andrew Lunn wrote:
> This switch is used by the 370-rd. Enable it and support for
> fixed-link phy configuration.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---
>  arch/arm/configs/mvebu_v7_defconfig | 2 ++
>  1 file changed, 2 insertions(+)

Applied to mvebu/defconfig

thx,

Jason.
