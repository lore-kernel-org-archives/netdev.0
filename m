From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: Accept ESP packets regardless of UDP
 encapsulation mode
Date: Thu, 04 Dec 2008 15:40:40 -0800 (PST)
Message-ID: <20081204.154040.198177832.davem@davemloft.net>
References: <1228396731.1643.57.camel@martin>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: martin@strongswan.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54532
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751648AbYLDXkk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 18:40:40 -0500
In-Reply-To: <1228396731.1643.57.camel@martin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin Willi <martin@strongswan.org>
Date: Thu, 04 Dec 2008 14:18:50 +0100

> An IPsec node speaking IKEv2 MUST accept incoming UDP encapsulated
> ESP packets, even if no NAT situation is detected. This is important
> if MOBIKE is in use. Some implementation keep the encapsulation
> mode if they move out of a NAT situation.

Applied, please provide a proper Signed-off-by line next time.
