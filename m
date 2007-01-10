From: David Miller <davem@davemloft.net>
Subject: Re: [PACKET]: Add PACKET_AUXDATA cmsg
Date: Wed, 10 Jan 2007 01:27:14 -0800 (PST)
Message-ID: <20070110.012714.30184541.davem@davemloft.net>
References: <20070110025435.GA19599@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44899
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932762AbXAJJ1P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jan 2007 04:27:15 -0500
To: herbert@gondor.apana.org.au
In-Reply-To: <20070110025435.GA19599@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 10 Jan 2007 13:54:35 +1100

> [PACKET]: Add optional checksum computation for recvmsg

This looks good, thanks Herbert.

I'll queue it up for 2.6.21
