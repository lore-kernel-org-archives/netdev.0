From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH V4 net-next 2/3] ipv6: add a flag to get the flow label used remotly
Date: Sun, 19 Jan 2014 16:23:10 +0100
Message-ID: <20140119152310.GA16462@order.stressinduktion.org>
References: <1389975305-12477-1-git-send-email-florent.fourcot@enst-bretagne.fr> <1389975305-12477-2-git-send-email-florent.fourcot@enst-bretagne.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:49557 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752380AbaASPXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jan 2014 10:23:11 -0500
Content-Disposition: inline
In-Reply-To: <1389975305-12477-2-git-send-email-florent.fourcot@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 17, 2014 at 05:15:04PM +0100, Florent Fourcot wrote:
> This information is already available via IPV6_FLOWINFO
> of IPV6_2292PKTOPTIONS, and them a filtering to get the flow label
> information. But it is probably logical and easier for users to add this
> here, and to control both sent/received flow label values with the
> IPV6_FLOWLABEL_MGR option.
> 
> Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>

Looks good.

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
