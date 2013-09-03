From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 7/8] net: ipv6: mld: introduce mld_{gq,ifc,dad}_stop_timer functions
Date: Tue, 3 Sep 2013 20:51:19 +0200
Message-ID: <20130903185119.GJ21729@order.stressinduktion.org>
References: <1378195178-21002-1-git-send-email-dborkman@redhat.com> <1378195178-21002-8-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:35280 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756032Ab3ICSvU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 14:51:20 -0400
Content-Disposition: inline
In-Reply-To: <1378195178-21002-8-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 03, 2013 at 09:59:37AM +0200, Daniel Borkmann wrote:
> We already have mld_{gq,ifc,dad}_start_timer() functions, so introduce
> mld_{gq,ifc,dad}_stop_timer() functions to reduce code size and make it
> more readable.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
