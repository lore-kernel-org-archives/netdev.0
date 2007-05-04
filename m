From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND][PATCH][XFRM] SAD info TLV aggregation
Date: Fri, 04 May 2007 12:55:52 -0700 (PDT)
Message-ID: <20070504.125552.98555980.davem@davemloft.net>
References: <463A7BF7.5010604@trash.net>
	<1178239828.4068.52.camel@localhost>
	<463B7724.8000300@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60949
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1161922AbXEDT4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 15:56:05 -0400
In-Reply-To: <463B7724.8000300@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Fri, 04 May 2007 20:10:44 +0200

> Here they are, thanks for your patience :)
> 
> I've changed them to XFRMA_SAD_... and XFRMA_SPD_... since
> UNSPEC and MAX are usually seperated by an underscore.

Applied, thanks everyone.
