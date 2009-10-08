From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Make UFO on master device independent of attached
 devices
Date: Wed, 07 Oct 2009 22:01:39 -0700 (PDT)
Message-ID: <20091007.220139.134319305.davem@davemloft.net>
References: <1254954265.31575.191.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: sri@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33894
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752253AbZJHFBo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2009 01:01:44 -0400
In-Reply-To: <1254954265.31575.191.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Wed, 07 Oct 2009 15:24:25 -0700

> Now that software UFO is supported, UFO can be enabled on master
> devices like bridge, bond even though the attached device doesn't
> support this feature in hardware.
> 
> This allows UFO to be used between KVM host and guest even when a
> physical interface attached to the bridge doesn't support UFO.
> 
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

Applied.
