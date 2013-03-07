From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] xfrm_user: constify netlink dispatch table
Date: Thu, 7 Mar 2013 08:47:57 +0100
Message-ID: <20130307074757.GC21448@secunet.com>
References: <1361711427-7880-1-git-send-email-minipli@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Mathias Krause <minipli@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53882 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751485Ab3CGHsA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Mar 2013 02:48:00 -0500
Content-Disposition: inline
In-Reply-To: <1361711427-7880-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 24, 2013 at 02:10:27PM +0100, Mathias Krause wrote:
> There is no need to modify the netlink dispatch table at runtime.
> 
> Signed-off-by: Mathias Krause <minipli@googlemail.com>

Applied to ipsec-next, thanks!
