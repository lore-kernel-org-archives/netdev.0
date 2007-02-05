From: David Miller <davem@davemloft.net>
Subject: Re: [PACKET]: Add PACKET_AUXDATA cmsg
Date: Sun, 04 Feb 2007 23:33:31 -0800 (PST)
Message-ID: <20070204.233331.07640405.davem@davemloft.net>
References: <20070110025435.GA19599@gondor.apana.org.au>
	<20070123233834.GA4923@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52075
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752763AbXBEHdd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 02:33:33 -0500
In-Reply-To: <20070123233834.GA4923@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 24 Jan 2007 10:38:34 +1100

> On Wed, Jan 10, 2007 at 01:54:35PM +1100, Herbert Xu wrote:
> > 
> > [PACKET]: Add optional checksum computation for recvmsg
> 
> Unfortunately I missed the fact the skb->cb is already used to store
> the sockaddr.  This patch fixes it up.

Both patch applied, thanks Herbert.
