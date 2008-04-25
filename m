From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] ibm_newemac: Increase MDIO timeouts
Date: Fri, 25 Apr 2008 02:04:27 -0400
Message-ID: <4811746B.9050202@pobox.com>
References: <20080423051832.63BF7DDF65@ozlabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	super.firetwister@googlemail.com
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57230 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756051AbYDYGE3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Apr 2008 02:04:29 -0400
In-Reply-To: <20080423051832.63BF7DDF65@ozlabs.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin Herrenschmidt wrote:
> This patch doubles the MDIO timeouts in EMAC as there are field
> cases where they are two short to communicate with some PHYs.
> 
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

applied


