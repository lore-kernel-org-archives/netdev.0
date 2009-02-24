From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/3] gre: used time_before for comparing jiffies
Date: Tue, 24 Feb 2009 15:13:52 +0800
Message-ID: <20090224071352.GA20925@gondor.apana.org.au>
References: <499E2C54.9000409@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:49273 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752550AbZBXHOC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 02:14:02 -0500
Content-Disposition: inline
In-Reply-To: <499E2C54.9000409@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wei Yongjun <yjwei@cn.fujitsu.com> wrote:
> The functions time_before is more robust for comparing
> jiffies against other values.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

Please resubmit these patches so that they can be reviewed again.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
