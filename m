From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tg3: Fix tx race condition
Date: Mon, 07 Aug 2006 20:05:56 -0700 (PDT)
Message-ID: <20060807.200556.40833596.davem@davemloft.net>
References: <1155005186.5328.13.camel@rh4>
	<20060808025117.GA13077@gondor.apana.org.au>
	<1155006336.5328.24.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:47844
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751227AbWHHDFy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 23:05:54 -0400
To: mchan@broadcom.com
In-Reply-To: <1155006336.5328.24.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Mon, 07 Aug 2006 20:05:36 -0700

> Actually, I can probably hide it in the TX_BUFFS_AVAIL() macro.

Sounds like a good idea.
