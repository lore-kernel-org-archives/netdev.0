From: David Miller <davem@davemloft.net>
Subject: Re: [1/2] e1000e: Invoke VLAN GRO handler
Date: Wed, 14 Jan 2009 20:38:09 -0800 (PST)
Message-ID: <20090114.203809.125438185.davem@davemloft.net>
References: <20090113092625.GA28015@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54980
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753230AbZAOEiI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 23:38:08 -0500
In-Reply-To: <20090113092625.GA28015@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 13 Jan 2009 20:26:25 +1100

> e1000e: Invoke VLAN GRO handler
> 
> Now that VLAN has GRO support as well, we can call its GRO handler
> as well.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-next-2.6
