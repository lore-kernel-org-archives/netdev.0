From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 1/1] ipv6: remove the destination condition on flow label sharing
Date: Fri, 1 Nov 2013 22:40:48 +0100
Message-ID: <20131101214048.GD30284@order.stressinduktion.org>
References: <1383322286-21464-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:44101 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752130Ab3KAVkt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Nov 2013 17:40:49 -0400
Content-Disposition: inline
In-Reply-To: <1383322286-21464-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 01, 2013 at 05:11:26PM +0100, Florent Fourcot wrote:
> In case of label sharing, it should be possible to use
> one label to more than one destination. This
> old restriction is not mandatory, so we can remove it.

Why?

Maybe I am not the only one up to date with recent advances in flow label
management but I guess others want to know why, too?

Please reflect this in your changelog.

Greetings,

  Hannes
