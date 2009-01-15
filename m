From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] b44: GFP_DMA skb should not escape from driver
Date: Thu, 15 Jan 2009 18:28:49 +0100
Message-ID: <496F7251.7030300@cosmosbay.com>
References: <20090115111537.GA994@gondor.apana.org.au> <496F4AD4.9080201@cosmosbay.com> <496F690A.2090606@cosmosbay.com> <200901151914.11421.ionut.leonte@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pekka Pietikainen <pp@ee.oulu.fi>,
	=?UTF-8?B?TWloYWkgRG9uyJt1?= <mihai.dontu@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Ionut Leonte <ionut.leonte@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw2.cosmosbay.com ([86.64.20.130]:54997 "EHLO gw2.cosmosbay.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752986AbZAOR3B convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 12:29:01 -0500
In-Reply-To: <200901151914.11421.ionut.leonte@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ionut Leonte a =C3=A9crit :
> Applied, seems to fix the problem.

Thanks for your report and testing !

