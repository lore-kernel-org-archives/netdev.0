From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 3/8] net/netfilter/ipvs/ip_vs_wrr.c: use lib/gcd.c
Date: Sun, 7 Jun 2009 18:41:38 +1000
Message-ID: <20090607084137.GB8007@verge.net.au>
References: <200906041616.22786.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux-MIPS <linux-mips@linux-mips.org>,
	Ralf Baechle <ralf@linux-mips.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:45482 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752830AbZFGIlk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jun 2009 04:41:40 -0400
Content-Disposition: inline
In-Reply-To: <200906041616.22786.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 04, 2009 at 04:16:21PM +0200, Florian Fainelli wrote:
> This patch removes the open-coded version of the
> greatest common divider to use lib/gcd.c, the latter
> also implementing the a < b case.
> 
> Signed-off-by: Florian Fainelli <florian@openwrt.org>

Acked-by: Simon Horman <horms@verge.net.au>
