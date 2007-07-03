From: David Miller <davem@davemloft.net>
Subject: Re: Resend: [PATCH] pktgen IPSEC 3/4: Introduce xfrm SAD only
 lookup
Date: Mon, 02 Jul 2007 22:41:24 -0700 (PDT)
Message-ID: <20070702.224124.43389729.davem@davemloft.net>
References: <466EA36E.80206@trash.net>
	<1181661564.4067.40.camel@localhost>
	<1181689563.4085.55.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, Robert.Olsson@data.slu.se,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	jmorris@namei.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56229
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751294AbXGCFlF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2007 01:41:05 -0400
In-Reply-To: <1181689563.4085.55.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Tue, 12 Jun 2007 19:06:03 -0400

> commit 4fe3190756589ef8155eb97fe725f2564f1fc77d
> Author: Jamal Hadi Salim <hadi@cyberus.ca>
> Date:   Tue Jun 12 12:35:39 2007 -0400
> 
>     [XFRM] Introduce standalone SAD lookup
>     This allows other in-kernel functions to do SAD lookups.
>     The only known user at the moment is pktgen.
>     
>     Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

Applied.
