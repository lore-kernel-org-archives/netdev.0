From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [RFC][PATCH 0/3][XFRM]: Support packet processing error statistics.
Date: Mon, 22 Oct 2007 17:42:06 +0900
Message-ID: <200710221742.06137.nakam@linux-ipv6.org>
References: <20071017.213523.58458049.davem@davemloft.net> <11930334662094-git-send-email-nakam@linux-ipv6.org> <20071022085040.GA17954@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.178.140.9] ([203.178.140.9]:36587 "EHLO mail.gomagoma.org"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750799AbXJVJDd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2007 05:03:33 -0400
In-Reply-To: <20071022085040.GA17954@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Monday 22 October 2007 17:50, Herbert Xu wrote:
> On Mon, Oct 22, 2007 at 03:11:06PM +0900, Masahide NAKAMURA wrote:
> > This patch introduces statistics about transformation error (or almost error)
> > factor at packet processing for developer.
> > It is not a SNMP/MIB specification from IPsec/MIPv6 but a counter
> > designed from current transformation source code.
> > 
> > Comment please.
> 
> Looks fine to me.  But could you hold onto this for a few days?
> I'm in the process of merging the input paths of IPv4 and IPv6.
> Once that's done you'll only need to count things once rather
> than once for IPv4 and again for IPv6.

No problem, I'll fix my patches upon your work and resend them.

Regards,

-- 
Masahide NAKAMURA
