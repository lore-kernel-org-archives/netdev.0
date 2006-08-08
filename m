From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tg3: Fix tx race condition
Date: Mon, 07 Aug 2006 21:21:35 -0700 (PDT)
Message-ID: <20060807.212135.77057626.davem@davemloft.net>
References: <1155006336.5328.24.camel@rh4>
	<20060807.200556.40833596.davem@davemloft.net>
	<1155010214.5328.27.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:11910
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932459AbWHHEVc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 00:21:32 -0400
To: mchan@broadcom.com
In-Reply-To: <1155010214.5328.27.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Mon, 07 Aug 2006 21:10:14 -0700

> Fix a subtle race condition between tg3_start_xmit() and tg3_tx()
> discovered by Herbert Xu <herbert@gondor.apana.org.au>:

This one looks good to me.  Herbert please ACK this if you agree.

Thanks a lot Michael.
