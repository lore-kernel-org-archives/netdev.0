From: David Miller <davem@davemloft.net>
Subject: Re: [Resend PATCH 3/3] TCP: Remove redundant checks when setting
 eff_sacks
Date: Wed, 16 Jul 2008 20:49:49 -0700 (PDT)
Message-ID: <20080716.204949.20726488.davem@davemloft.net>
References: <396556a20805301217k293e5718h6bbf02bfe069013@europa>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: agl@imperialviolet.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60020
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752198AbYGQDtu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 23:49:50 -0400
In-Reply-To: <396556a20805301217k293e5718h6bbf02bfe069013@europa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Adam Langley" <agl@imperialviolet.org>
Date: Tue, 15 Jul 2008 09:30:40 -0700

> Remove redundant checks when setting eff_sacks and make the number of SACKs a
> compile time constant. Now that the options code knows how many SACK blocks can
> fit in the header, we don't need to have the SACK code guessing at it.
> 
> Signed-off-by: Adam Langley <agl@imperialviolet.org>

This one looks OK, please resned it when you fix up the other
two.

Thanks.
