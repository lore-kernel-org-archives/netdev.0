From: Daniel Trautmann <dtrautmann@ibhsoftec.com>
Subject: Re: [PATCH] drivers: net: cpsw: add support for fixed-links.
Date: Tue, 10 Nov 2015 12:39:34 +0100
Message-ID: <20151110113931.GB20442@dt-ub1404lts.ENTWDOM.local>
References: <1447097054-4658-1-git-send-email-dtrautmann@ibhsoftec.com>
 <20151109.224951.1754592431174323682.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <mugunthanvnm@ti.com>, <balbi@ti.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.216]:65343 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751027AbbKJLji (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2015 06:39:38 -0500
Content-Disposition: inline
In-Reply-To: <20151109.224951.1754592431174323682.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 09, 2015 at 10:49:51PM -0500, David Miller wrote:
> From: Daniel Trautmann <dtrautmann@ibhsoftec.com>
> Date: Mon, 9 Nov 2015 20:24:14 +0100
> 
> > Add support for fixed-links in configurations without PHY.
> > (e.g. connection to a switch, SGMII point to point, SFPs)
> > 
> > Check: Documentation/devicetree/bindings/net/fixed-link.txt.
> > 
> > Signed-off-by: Daniel Trautmann <dtrautmann@ibhsoftec.com>
> 
> This patch doesn't apply cleanly at all.

Sorry, I was working on the wrong branch.
I found there is a similar patch already in netdev-next, I will
check this an submit a new Patch if necessary.
