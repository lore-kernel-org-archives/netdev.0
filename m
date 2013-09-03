From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 6/8] net: ipv6: mld: refactor query processing into v1/v2 functions
Date: Tue, 3 Sep 2013 20:49:39 +0200
Message-ID: <20130903184939.GI21729@order.stressinduktion.org>
References: <1378195178-21002-1-git-send-email-dborkman@redhat.com> <1378195178-21002-7-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:35274 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758348Ab3ICStk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 14:49:40 -0400
Content-Disposition: inline
In-Reply-To: <1378195178-21002-7-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 03, 2013 at 09:59:36AM +0200, Daniel Borkmann wrote:
> Make igmp6_event_query() a bit easier to read by refactoring code
> parts into mld_process_v1() and mld_process_v2().
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
