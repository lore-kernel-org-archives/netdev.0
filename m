From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2][KEY]: Clean up proc files creation a bit.
Date: Sat, 09 Feb 2008 23:19:23 -0800 (PST)
Message-ID: <20080209.231923.202749558.davem@davemloft.net>
References: <47AC46F4.60405@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56375
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757206AbYBJHSv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2008 02:18:51 -0500
In-Reply-To: <47AC46F4.60405@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 08 Feb 2008 15:11:32 +0300

> Mainly this removes ifdef-s from inside the ipsec_pfkey_init.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
