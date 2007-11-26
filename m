From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/4] fib_hash: kmalloc + memset conversion to kzalloc
Date: Mon, 26 Nov 2007 23:31:43 +0800
Message-ID: <20071126153143.GG28022@gondor.apana.org.au>
References: <000401c83016$78a9d930$9c94fea9@jason>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joonwoo Park <joonwpark81@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3917 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751970AbXKZPbp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 10:31:45 -0500
Content-Disposition: inline
In-Reply-To: <000401c83016$78a9d930$9c94fea9@jason>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 26, 2007 at 10:24:03AM +0000, Joonwoo Park wrote:
> fib_hash: kmalloc + memset conversion to kzalloc
> fix to avoid memset entirely.

Patch applied.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
