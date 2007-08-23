From: David Gibson <david@gibson.dropbear.id.au>
Subject: Re: [PATCH] ucc_geth: kill unused include
Date: Thu, 23 Aug 2007 12:54:38 +1000
Message-ID: <20070823025438.GE7042@localhost.localdomain>
References: <Pine.LNX.4.64.0708222144440.6464@blarg.am.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	Li Yang <leoli@freescale.com>,
	Paul Mackerras <paulus@samba.org>, linuxppc-dev@ozlabs.org
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:40388 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756506AbXHWC7R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2007 22:59:17 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0708222144440.6464@blarg.am.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 22, 2007 at 09:51:03PM -0500, Kumar Gala wrote:
> The ucc_geth_mii code is based on the gianfar_mii code that use to include
> ocp.h.  ucc never need this and it causes issues when we want to kill
> arch/ppc includes from arch/powerpc.
> 
> Signed-off-by: Kumar Gala <galak@kernel.crashing.org>

Acked-by: David Gibson <david@gibson.dropbear.id.au>

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson
