From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: 2.6.24-rc2: Network commit causes SLUB performance regression with tbench
Date: Thu, 15 Nov 2007 11:21:36 +1100
Message-ID: <200711151121.37080.nickpiggin@yahoo.com.au>
References: <200711140927.39796.nickpiggin@yahoo.com.au> <20071114114844.GA13927@gondor.apana.org.au> <20071114.154616.46285694.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, clameter@sgi.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp103.mail.mud.yahoo.com ([209.191.85.213]:41122 "HELO
	smtp103.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753363AbXKOAVp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 19:21:45 -0500
In-Reply-To: <20071114.154616.46285694.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 15 November 2007 10:46, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Wed, 14 Nov 2007 19:48:44 +0800

> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>
> Applied and I'll queue it up for -stable too.

Good result. Thanks, everyone!
