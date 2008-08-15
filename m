From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] tun: fallback if skb_alloc() fails on big packets
Date: Fri, 15 Aug 2008 15:15:31 -0700 (PDT)
Message-ID: <20080815.151531.139141076.davem@davemloft.net>
References: <20080812101409.GA22114@gondor.apana.org.au>
	<200808131324.56071.rusty@rustcorp.com.au>
	<48A5C643.8020506@qualcomm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: maxk@qualcomm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49689
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751352AbYHOWPb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2008 18:15:31 -0400
In-Reply-To: <48A5C643.8020506@qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Max Krasnyansky <maxk@qualcomm.com>
Date: Fri, 15 Aug 2008 11:09:07 -0700

> TUN changes look good to me. Ack.

I've applied Rusty's patch.  I have no suggestions on how to handle
his situation better :)
