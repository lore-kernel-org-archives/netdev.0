From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 3/5] ipv6: remove rcv_tclass of ipv6_pinfo
Date: Tue, 10 Dec 2013 00:42:08 +0100
Message-ID: <20131209234208.GC7396@order.stressinduktion.org>
References: <1386514021-11646-1-git-send-email-florent.fourcot@enst-bretagne.fr> <1386514021-11646-3-git-send-email-florent.fourcot@enst-bretagne.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:43547 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751298Ab3LIXmJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 18:42:09 -0500
Content-Disposition: inline
In-Reply-To: <1386514021-11646-3-git-send-email-florent.fourcot@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 08, 2013 at 03:46:59PM +0100, Florent Fourcot wrote:
> tclass information in now already stored in rcv_flowinfo
> We do not need to store the same information twice.
> 
> Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>

Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
