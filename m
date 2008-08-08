From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: (whitespace only) fix confusing indentation
Date: Thu, 07 Aug 2008 20:28:02 -0700 (PDT)
Message-ID: <20080807.202802.193696626.davem@davemloft.net>
References: <396556a20805301217k293e5718h6bbf02bfe069060@europa>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: agl@imperialviolet.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60017
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752202AbYHHD2B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 23:28:01 -0400
In-Reply-To: <396556a20805301217k293e5718h6bbf02bfe069060@europa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Adam Langley" <agl@imperialviolet.org>
Date: Thu, 7 Aug 2008 18:37:12 -0700

> The indentation in part of tcp_minisocks makes it look like one of the if
> statements is much more important than it actually is.
> 
> Signed-off-by: Adam Langley <agl@imperialviolet.org>

Indeed, how awful and confusing.

Patch applied, thanks Adam.
