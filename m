From: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
Subject: Re: [PATCH] fib_rules: add minimum prefix length
Date: Thu, 25 Jul 2013 20:28:18 +0200
Message-ID: <20130725182818.GZ10216@zirkel.wertarbyte.de>
References: <20130723220221.GP10216@zirkel.wertarbyte.de>
 <20130724021420.GA10670@order.stressinduktion.org>
 <20130725162931.GX10216@zirkel.wertarbyte.de>
 <20130725181712.GB24007@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zirkel.wertarbyte.de ([188.40.44.137]:48984 "EHLO
	zirkel.wertarbyte.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755857Ab3GYS2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 14:28:21 -0400
Received: from stefan by zirkel.wertarbyte.de with local (Exim 4.72)
	(envelope-from <stefan.tomanek@wertarbyte.de>)
	id 1V2QGw-0004fy-S5
	for netdev@vger.kernel.org; Thu, 25 Jul 2013 20:28:18 +0200
Content-Disposition: inline
In-Reply-To: <20130725181712.GB24007@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dies schrieb Hannes Frederic Sowa (hannes@stressinduktion.org):

> > I however did like the idea of adding IPv6 support, so I did -
> > I'll post the new patch later on.
> 
> Cool, thanks.

I've just completed the patch and sent it to the list, and I also placed the
changes in my github account, just in case anyone wants to take a quick peek:
https://github.com/wertarbyte/linux/compare/prefixlength
