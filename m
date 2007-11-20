From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 1/5] powerpc: document rgmii-rxid and rgmii-txid
 phy-connection-types
Date: Mon, 19 Nov 2007 23:53:25 -0600 (CST)
Message-ID: <Pine.LNX.4.64.0711192353110.1217@blarg.am.freescale.net>
References: <20071105121535.c423d095.kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Li Yang <leoli@freescale.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, jgarzik@pobox.com, paulus@samba.org
To: Kim Phillips <kim.phillips@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:37005 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755575AbXKTFzd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Nov 2007 00:55:33 -0500
In-Reply-To: <20071105121535.c423d095.kim.phillips@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 5 Nov 2007, Kim Phillips wrote:

> A h/w bug requires we program the PHY in RGMII mode for internal delay
> on the receive or transmit side only; document the new property values.
>
> Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
> ---
>  Documentation/powerpc/booting-without-of.txt |    5 +++--
>  1 files changed, 3 insertions(+), 2 deletions(-)
>

applied.

- k
