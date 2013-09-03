From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 2/8] net: ipv6: mld: clean up MLD_V1_SEEN macro
Date: Tue, 3 Sep 2013 19:55:47 +0200
Message-ID: <20130903175547.GD21729@order.stressinduktion.org>
References: <1378195178-21002-1-git-send-email-dborkman@redhat.com> <1378195178-21002-3-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:35100 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754571Ab3ICRzs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 13:55:48 -0400
Content-Disposition: inline
In-Reply-To: <1378195178-21002-3-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 03, 2013 at 09:59:32AM +0200, Daniel Borkmann wrote:
> Replace the macro with a function to make it more readable. GCC will
> eventually decide whether to inline this or not (also, that's not
> fast-path anyway).
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
