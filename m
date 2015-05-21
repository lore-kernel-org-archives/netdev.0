From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 7/7] mac80211: Switch to new AEAD interface
Date: Thu, 21 May 2015 13:20:49 +0200
Message-ID: <1432207249.2343.9.camel@sipsolutions.net>
References: <20150521103938.GA23035@gondor.apana.org.au>
	 <E1YvNxS-00063i-AZ@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:43961 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754017AbbEULU6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2015 07:20:58 -0400
In-Reply-To: <E1YvNxS-00063i-AZ@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-05-21 at 18:44 +0800, Herbert Xu wrote:
> This patch makes use of the new AEAD interface which uses a single
> SG list instead of separate lists for the AD and plain text.

Looks fine - want me to run any tests on it?

johannes
