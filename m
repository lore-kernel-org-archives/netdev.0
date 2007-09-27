From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PKT_SCHED]: Add stateless NAT
Date: Thu, 27 Sep 2007 15:39:34 +0200
Message-ID: <46FBB296.8020901@trash.net>
References: <20070927073446.GA14643@gondor.apana.org.au> <20070927092512.GD29329@2ka.mipt.ru> <20070927093358.GA15357@gondor.apana.org.au> <20070927100753.GA22323@2ka.mipt.ru> <20070927102916.GA15749@gondor.apana.org.au> <20070927124120.GA8897@2ka.mipt.ru> <20070927124515.GA16706@gondor.apana.org.au> <20070927131008.GA15997@2ka.mipt.ru> <20070927132037.GA17056@gondor.apana.org.au> <20070927132941.GB25353@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	jamal <hadi@cyberus.ca>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58526 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754983AbXI0Njg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 09:39:36 -0400
In-Reply-To: <20070927132941.GB25353@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> On Thu, Sep 27, 2007 at 09:20:37PM +0800, Herbert Xu (herbert@gondor.apana.org.au) wrote:
> 
>>How about putting it in net/core/utils.c?
> 
> 
> I knew, that was a bad idea to try to fix netfilter dependency :)
> 
> diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h


This looks good to me.
