From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 2/3] [POWERPC] fsl_soc: add support for gianfar for
 fixed-link property
Date: Fri, 18 Jan 2008 00:46:32 -0600 (CST)
Message-ID: <Pine.LNX.4.64.0801180046190.16260@blarg.am.freescale.net>
References: <20071206225121.31080.86606.stgit@localhost.localdomain>
 <20071206225131.31080.7872.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Paul Mackerras <paulus@samba.org>, netdev@vger.kernel.org,
	linuxppc-dev <linuxppc-dev@ozlabs.org>, netdev@vger.kernel.org
To: Vitaly Bordug <vitb@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:47306 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750913AbYARGs4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jan 2008 01:48:56 -0500
In-Reply-To: <20071206225131.31080.7872.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 7 Dec 2007, Vitaly Bordug wrote:

>
> fixed-link says: register new "Fixed/emulated PHY", i.e. PHY that
> not connected to the real MDIO bus.
>
> Signed-off-by: Vitaly Bordug <vitb@kernel.crashing.org>
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
>
> ---
>
>  Documentation/powerpc/booting-without-of.txt |    4 +
>  arch/powerpc/sysdev/fsl_soc.c                |   79 ++++++++++++++++++++------
>  2 files changed, 66 insertions(+), 17 deletions(-)
>

applied.

- k
