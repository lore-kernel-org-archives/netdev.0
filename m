From: Stephan Mueller <smueller@chronox.de>
Subject: Re: [v2 PATCH 13/13] crypto: algif_aead - Switch to new AEAD interface
Date: Tue, 26 May 2015 09:57:51 +0200
Message-ID: <5101027.rdCY05rkLJ@tauon>
References: <20150522082708.GA3507@gondor.apana.org.au> <1720790.K1nOQU1Nxi@tachyon.chronox.de> <20150526073605.GA6530@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20150526073605.GA6530@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Dienstag, 26. Mai 2015, 15:36:05 schrieb Herbert Xu:

Hi Herbert,
>
>In order to allow this to be done I'm going to disable the AEAD
>user-space interface in 4.1 so that we have time to fix it properly
>for 4.2.

Ok. Would you look into that one or shall I do that?

Ciao
Stephan
