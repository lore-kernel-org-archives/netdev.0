From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 5/5] powerpc: handle mpc8360 rev. 2.1 RGMII timing erratum
Date: Mon, 19 Nov 2007 23:53:02 -0600 (CST)
Message-ID: <Pine.LNX.4.64.0711192352440.1217@blarg.am.freescale.net>
References: <20071105121551.a28b5446.kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Li Yang <leoli@freescale.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, jgarzik@pobox.com, paulus@samba.org
To: Kim Phillips <kim.phillips@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:36994 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755575AbXKTFzF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Nov 2007 00:55:05 -0500
In-Reply-To: <20071105121551.a28b5446.kim.phillips@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 5 Nov 2007, Kim Phillips wrote:

> if on a rev. 2.1, adjust UCC clock and data timing characteristics
> as specified in the rev.2.1 erratum #2.
>
> Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
> ---
>  arch/powerpc/platforms/83xx/mpc836x_mds.c |   31 ++++++++++++++++++++++++++--
>  1 files changed, 28 insertions(+), 3 deletions(-)
>

applied.

- k
