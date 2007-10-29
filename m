From: David Miller <davem@davemloft.net>
Subject: Re: Configuring the same IP on multiple addresses
Date: Mon, 29 Oct 2007 15:42:58 -0700 (PDT)
Message-ID: <20071029.154258.39630263.davem@davemloft.net>
References: <47262079.90507@hp.com>
	<20071029.152559.174870963.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56108
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751340AbXJ2Wm4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2007 18:42:56 -0400
In-Reply-To: <20071029.152559.174870963.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Mon, 29 Oct 2007 15:25:59 -0700 (PDT)

> Can you guys please just state upfront what virtualization
> issue is made more difficult by features you want to remove?

Sorry, I mentioned "virtualization" because that's been the
largest majority of the cases being presented lately.

I suspect in your case it's some multicast or SCTP thing :-)
