From: Brice Goglin <brice@myri.com>
Subject: Re: [PATCH net-next-2.6] drivers/net: Move && and || to end of previous
 line
Date: Fri, 04 Dec 2009 14:10:01 +0100
Message-ID: <4B190A29.5080905@myri.com>
References: <1259001504.16503.79.camel@Joe-Laptop.home>	 <20091123.104130.117837098.davem@davemloft.net>	 <1259528449.29779.194.camel@Joe-Laptop.home>	 <20091129.165557.84377714.davem@davemloft.net> <1259863101.22783.63.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1951 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932110AbZLDNlk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Dec 2009 08:41:40 -0500
In-Reply-To: <1259863101.22783.63.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches wrote:
> Only files where David Miller is the primary git-signer.
> wireless, wimax, ixgbe, etc are not modified.
>   

What's the point? Having them at the beginning of the next line is
easier to read from my point of view.

Brice

