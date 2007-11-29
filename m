From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/2] [IPSEC]: Reinject v6 packet on input instead of	calling
 netfilter
Date: Thu, 29 Nov 2007 21:55:57 +0100
Message-ID: <474F275D.3030401@trash.net>
References: <1196369551.4437.24.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56237 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757325AbXK2U41 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 15:56:27 -0500
In-Reply-To: <1196369551.4437.24.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:

[ can't quote because non-inline attachment ]

I think Yoshifuji had some objections to this because extension
headers will be processed twice.


