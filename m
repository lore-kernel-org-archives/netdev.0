From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next-2.6] drivers/net: Move && and || to end of
 previous line
Date: Fri, 04 Dec 2009 09:21:11 -0800
Message-ID: <1259947271.22783.120.camel@Joe-Laptop.home>
References: <1259001504.16503.79.camel@Joe-Laptop.home>
	 <20091123.104130.117837098.davem@davemloft.net>
	 <1259528449.29779.194.camel@Joe-Laptop.home>
	 <20091129.165557.84377714.davem@davemloft.net>
	 <1259863101.22783.63.camel@Joe-Laptop.home>  <4B190A29.5080905@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Brice Goglin <brice@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1294 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756756AbZLDRVF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Dec 2009 12:21:05 -0500
In-Reply-To: <4B190A29.5080905@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-12-04 at 14:10 +0100, Brice Goglin wrote:
> Joe Perches wrote:
> > Only files where David Miller is the primary git-signer.
> > wireless, wimax, ixgbe, etc are not modified.
> What's the point? Having them at the beginning of the next line is
> easier to read from my point of view.

It's just a stupid consistency thing.


