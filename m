From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC] xfrm{4,6}: only report errors back to local sockets if we don't cross address family
Date: Thu, 1 Aug 2013 10:11:50 +0200
Message-ID: <20130801081150.GF3688@order.stressinduktion.org>
References: <20130729145017.GD2490@order.stressinduktion.org> <20130730082118.GA25511@secunet.com> <20130730083017.GA7068@order.stressinduktion.org> <20130730102611.GB25511@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, vi0oss@gmail.com
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:52991 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752590Ab3HAILw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 04:11:52 -0400
Content-Disposition: inline
In-Reply-To: <20130730102611.GB25511@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 30, 2013 at 12:26:11PM +0200, Steffen Klassert wrote:
> Lets see if anyone else has an opinion to that. I'll go
> and look what we can do if we have to fix it in the IPsec
> code in the meantime.

If you have not yet done so, I would try to find a solution over the weekend.

Thanks,

  Hannes
