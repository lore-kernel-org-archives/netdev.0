From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] tun: Limit amount of queued packets per device
Date: Wed, 04 Feb 2009 16:56:30 -0800 (PST)
Message-ID: <20090204.165630.95274793.davem@davemloft.net>
References: <20090204104825.GA21257@gondor.apana.org.au>
	<E1LUfJt-0005ZQ-4D@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59125
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750847AbZBEA4d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2009 19:56:33 -0500
In-Reply-To: <E1LUfJt-0005ZQ-4D@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 04 Feb 2009 21:49:25 +1100

> tun: Limit amount of queued packets per device

When adding new tun ioctls, you need to add compat entries
to fs/compat_ioctl.c

Please make this correction and resubmit.

Thanks.
