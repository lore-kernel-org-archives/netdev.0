From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v4 net-next 3/3] ipv6: add flowlabel_consistency sysctl
Date: Sun, 19 Jan 2014 16:24:31 +0100
Message-ID: <20140119152431.GB16462@order.stressinduktion.org>
References: <1389975305-12477-1-git-send-email-florent.fourcot@enst-bretagne.fr> <1389975305-12477-3-git-send-email-florent.fourcot@enst-bretagne.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:49562 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752231AbaASPYc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jan 2014 10:24:32 -0500
Content-Disposition: inline
In-Reply-To: <1389975305-12477-3-git-send-email-florent.fourcot@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 17, 2014 at 05:15:05PM +0100, Florent Fourcot wrote:
> With the introduction of IPV6_FL_F_REFLECT, there is no guarantee of
> flow label unicity. This patch introduces a new sysctl to protect the old
> behaviour, enable by default.
> 
> Changelog of V3:
>  * rename ip6_flowlabel_consistency to flowlabel_consistency
>  * use net_info_ratelimited()
>  * checkpatch cleanups
> 
> Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>

Also ok, thanks!

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
