From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next V2 1/3] net: Add GRO support for UDP encapsulating
 protocols
Date: Wed, 8 Jan 2014 18:31:44 +0200
Message-ID: <52CD7D70.9040406@mellanox.com>
References: <1389108594-665-1-git-send-email-ogerlitz@mellanox.com>	<1389108594-665-2-git-send-email-ogerlitz@mellanox.com>	<CA+mtBx_UDWVP2KEB04d-kS4fB1DyYX4m-sC8YOZDy-Wty3cmtA@mail.gmail.com>	<CAJZOPZKecwB9S_+goH2SvcXS+03rYk=73eVNBUoEMz=M5484RA@mail.gmail.com>	<CA+mtBx-HRi4ttijScF8DKtdooeOyjzPXwq7T69vNaPSodZh1dQ@mail.gmail.com>	<52CD7899.5090707@mellanox.com> <CA+mtBx8hnTtXD9ePSzcu2RGRghbmd4Wyu10HPmUu=gXcw5FaLA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <or.gerlitz@gmail.com>, Jerry Chu <hkchu@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Yan Burman <yanb@mellanox.com>,
	Shlomo Pongratz <shlomop@mellanox.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog105.obsmtp.com ([207.126.144.119]:49889 "EHLO
	eu1sys200aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757225AbaAHQcR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 11:32:17 -0500
In-Reply-To: <CA+mtBx8hnTtXD9ePSzcu2RGRghbmd4Wyu10HPmUu=gXcw5FaLA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/01/2014 18:29, Tom Herbert wrote:
> [...] Let's get the basic UDP GRO support in, and then I think adding support for direct encapsulation can be done without API change in your proposed scheme
sounds good to me
