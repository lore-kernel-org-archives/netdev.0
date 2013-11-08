From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v2 3/3] ipv6: protect flow label renew against GC
Date: Fri, 8 Nov 2013 13:29:03 +0100
Message-ID: <20131108122903.GB5876@order.stressinduktion.org>
References: <1383843194-22945-1-git-send-email-florent.fourcot@enst-bretagne.fr> <1383843194-22945-3-git-send-email-florent.fourcot@enst-bretagne.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:57991 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752991Ab3KHM3E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 07:29:04 -0500
Content-Disposition: inline
In-Reply-To: <1383843194-22945-3-git-send-email-florent.fourcot@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 07, 2013 at 05:53:14PM +0100, Florent Fourcot wrote:
> Take ip6_fl_lock before to read and update
> a label.
> 
> v2: protect only the relevant code
> 
> Reported-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks for fixing this,

  Hannes
