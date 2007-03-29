From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: Add TCP connection abort IOCTL
Date: Thu, 29 Mar 2007 11:41:39 -0700 (PDT)
Message-ID: <20070329.114139.55510589.davem@davemloft.net>
References: <20070327214754.GA11677@dag-work>
	<20070327.153025.45876618.davem@davemloft.net>
	<46d726f90703290756k1894b0aal8df85d46d8c2a25e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dagriego@gmail.com, netdev@vger.kernel.org
To: predrag.hodoba@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48076
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S934320AbXC2Slm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2007 14:41:42 -0400
In-Reply-To: <46d726f90703290756k1894b0aal8df85d46d8c2a25e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Predrag Hodoba" <predrag.hodoba@gmail.com>
Date: Thu, 29 Mar 2007 16:56:22 +0200

> Need for such an API is to a degree indicated in the Carrier Grade Linux
> requirements by The Linux Foundation (former OSDL).

Something being in the CGL specification is to me exactly a great
reason NOT to add it.  That specification is so full of garbage it's
unbelievable.

Thanks, you've given me one more reason not to even remotely consider
adding this feature.
