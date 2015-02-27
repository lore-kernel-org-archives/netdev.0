From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: Kernel Panic with vti Interfaces
Date: Fri, 27 Feb 2015 11:35:06 +0100
Message-ID: <20150227103506.GD20631@secunet.com>
References: <54EC4C63.3050006@marcant.net>
 <20150226114052.GB20631@secunet.com>
 <54EFB312.8040309@marcant.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <herbert@gondor.apana.org.au>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: Andre Valentin <avalentin@marcant.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:44429 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752382AbbB0KfK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Feb 2015 05:35:10 -0500
Content-Disposition: inline
In-Reply-To: <54EFB312.8040309@marcant.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 27, 2015 at 12:58:10AM +0100, Andre Valentin wrote:
> 
> >
> > I have never seen this, is the patch above the only locally
> > applied patch?
> No, the kernel is coming from the current openwrt 3.18 trunk.
> It's 3.18.7 with serveral patches coming from openwrt.
> I already checked the IPsec related patches but the error
> persisted.
> 
> I will remove more patches to be sure and forward my results!

Please try with an unpatched kernel from kernel.org, thanks!
