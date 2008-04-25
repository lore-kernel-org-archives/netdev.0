From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH] ibm_newemac: Increase MDIO timeouts
Date: Fri, 25 Apr 2008 16:57:03 -0400
Message-ID: <20080425165703.864e63bd.billfink@mindspring.com>
References: <20080423051832.63BF7DDF65@ozlabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <jgarzik@pobox.com>, <netdev@vger.kernel.org>,
	<linuxppc-dev@ozlabs.org>, <super.firetwister@googlemail.com>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-galgo.atl.sa.earthlink.net ([209.86.89.61]:60848 "EHLO
	elasmtp-galgo.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1763265AbYDYU5O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2008 16:57:14 -0400
In-Reply-To: <20080423051832.63BF7DDF65@ozlabs.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 23 Apr 2008, Benjamin Herrenschmidt wrote:

> This patch doubles the MDIO timeouts in EMAC as there are field
> cases where they are two short to communicate with some PHYs.

I guess them being "two short" is why they needed to be doubled.  :-)

						-Bill
