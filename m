From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] phylib: Add Realtek 821x eth PHY support
Date: Wed, 30 Jan 2008 03:49:13 -0500
Message-ID: <47A03A09.1090605@pobox.com>
References: <20080124202826.a50fa29c.kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Johnson Leung <r58129@freescale.com>,
	Kevin Lam <r43770@freescale.com>,
	Joe D'Abbraccio <ljd015@freescale.com>
To: Kim Phillips <kim.phillips@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:33481 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757601AbYA3ItP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2008 03:49:15 -0500
In-Reply-To: <20080124202826.a50fa29c.kim.phillips@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kim Phillips wrote:
> this PHY present on the MPC8315E and MPC837xE RDB boards.
> 
> Signed-off-by: Johnson Leung <r58129@freescale.com>
> Signed-off-by: Kevin Lam <r43770@freescale.com>
> Signed-off-by: Joe D'Abbraccio <ljd015@freescale.com>
> Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
> ---
>  drivers/net/phy/Kconfig   |    5 +++
>  drivers/net/phy/Makefile  |    1 +
>  drivers/net/phy/realtek.c |   80 +++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 86 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/phy/realtek.c

applied (though admittedly the filename seems a bit too generic)


