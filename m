From: David Miller <davem@davemloft.net>
Subject: Re: oopses since "net: Optimize memory usage when splicing from
 sockets"
Date: Thu, 30 Apr 2009 05:40:40 -0700 (PDT)
Message-ID: <20090430.054040.31760584.davem@davemloft.net>
References: <20090430031626.GM14729@mail.wantstofly.org>
	<20090430084321.GA2753@ami.dom.local>
	<20090430124036.GN14729@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47428
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754597AbZD3Mkq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2009 08:40:46 -0400
In-Reply-To: <20090430124036.GN14729@mail.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Thu, 30 Apr 2009 14:40:36 +0200

> With your patch, at least the oops is gone, and I guess it makes
> sense and looks correct, so:
> 
> 	Tested-by: Lennert Buytenhek <buytenh@wantstofly.org>

Thanks for testing Lennert.

I'll queue this up for -stable too.
