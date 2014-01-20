From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v2] ipv6: enable anycast addresses as source addresses in ICMPv6 error messages
Date: Mon, 20 Jan 2014 16:54:43 +0100
Message-ID: <20140120155443.GC27055@order.stressinduktion.org>
References: <1390147236-3660-1-git-send-email-fx.lebail@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, David Stevens <dlstevens@us.ibm.com>,
	Bill Fink <billfink@mindspring.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:52557 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751887AbaATPyo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jan 2014 10:54:44 -0500
Content-Disposition: inline
In-Reply-To: <1390147236-3660-1-git-send-email-fx.lebail@yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 19, 2014 at 05:00:36PM +0100, Francois-Xavier Le Bail wrote:
> - Uses ipv6_anycast_destination() in icmp6_send().
> 
> Suggested-by: Bill Fink <billfink@mindspring.com>
> Signed-off-by: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
> ---
> v2: Consideration of a Hannes's concern : No sysctl is needed for this change.
>     No need for a new check function.

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
