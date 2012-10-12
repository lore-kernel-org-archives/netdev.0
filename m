From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] bridge: don't flood multicast packets if no snooping
 entry
Date: Fri, 12 Oct 2012 10:27:08 +0800
Message-ID: <20121012022708.GA17230@gondor.apana.org.au>
References: <1350004643-3786-1-git-send-email-minggr@gmail.com>
 <20121012014852.GA17025@gondor.apana.org.au>
 <CAF1ivSbpwJqauL+S7FeozrkjkMcUyuOivv_Qk68Hme4uipq-yw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Lin Ming <minggr@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sting.hengli.com.au ([178.18.18.71]:52210 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757056Ab2JLC1K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 22:27:10 -0400
Content-Disposition: inline
In-Reply-To: <CAF1ivSbpwJqauL+S7FeozrkjkMcUyuOivv_Qk68Hme4uipq-yw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 12, 2012 at 10:14:00AM +0800, Lin Ming wrote:
>
> Do you mean adding a sysfs entry, for example
> /sys/class/net/br0/bridge/multicast_no_flood ?

Yes something like that.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
