From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 3/8] net: ipv6: mld: get rid of MLDV2_MRC and simplify calculation
Date: Tue, 3 Sep 2013 20:09:03 +0200
Message-ID: <20130903180903.GE21729@order.stressinduktion.org>
References: <1378195178-21002-1-git-send-email-dborkman@redhat.com> <1378195178-21002-4-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:35128 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753889Ab3ICSJE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 14:09:04 -0400
Content-Disposition: inline
In-Reply-To: <1378195178-21002-4-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 03, 2013 at 09:59:33AM +0200, Daniel Borkmann wrote:
> Get rid of MLDV2_MRC and use our new macros for mantisse and
> exponent to calculate Maximum Response Delay out of the Maximum
> Response Code.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
