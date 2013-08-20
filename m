From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 3/3] net: ipv6: mcast: minor: use defines for rfc3810/8.1 lengths
Date: Tue, 20 Aug 2013 13:56:11 +0200
Message-ID: <20130820115611.GE3938@order.stressinduktion.org>
References: <1376994122-3022-1-git-send-email-dborkman@redhat.com> <1376994122-3022-4-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:34587 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750982Ab3HTL4M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 07:56:12 -0400
Content-Disposition: inline
In-Reply-To: <1376994122-3022-4-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 20, 2013 at 12:22:02PM +0200, Daniel Borkmann wrote:
> Instead of hard-coding length values, use a define to make it clear
> where those lengths come from.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Nice cleanups, thanks Daniel!
