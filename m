From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch] IPVS: ip_vs_lblcr: use list head
Date: Fri, 26 Feb 2010 17:45:41 +0100
Message-ID: <4B87FAB5.3070505@trash.net>
References: <20100226030211.GB6111@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
	Wensong Zhang <wensong@linux-vs.org>,
	Julian Anastasov <ja@ssi.bg>,
	"David S. Miller" <davem@davemloft.net>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59518 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965388Ab0BZQpn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 11:45:43 -0500
In-Reply-To: <20100226030211.GB6111@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simon Horman wrote:
> Use list_head rather than a custom list implementation.

Looks good, applied.
