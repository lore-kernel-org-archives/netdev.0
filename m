From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: iproute2 and aead
Date: Wed, 17 Sep 2008 22:09:45 -0700
Message-ID: <20080917220945.1277dad6@extreme>
References: <61362e760808131459l1548c956s47b4e5d3c67144fa@mail.gmail.com>
	<20080830045710.GA17501@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Barry G <mr.scada@gmail.com>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43557 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750710AbYIRFJr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Sep 2008 01:09:47 -0400
In-Reply-To: <20080830045710.GA17501@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 30 Aug 2008 14:57:10 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> ip: xfrm: Add AEAD support
> 
> This patch allows the user to create/manage AEAD algorithms with
> the ip xfrm command.  AEAD algorithms are also known as combined-
> mode algorithms.  They provide the functionality of encryption
> algorithms as well as authentication algorithms.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
applied (had do some manual merge fixing)
