From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/7] Final ADSL-optimizer patch series
Date: Sun, 13 Apr 2008 22:40:28 -0700 (PDT)
Message-ID: <20080413.224028.34308757.davem@davemloft.net>
References: <Pine.LNX.4.64.0804092249550.21022@ask.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen.hemminger@vyatta.com, netdev@vger.kernel.org,
	kaber@trash.net
To: hawk@diku.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41708
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752343AbYDNFk1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 01:40:27 -0400
In-Reply-To: <Pine.LNX.4.64.0804092249550.21022@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <hawk@diku.dk>
Date: Wed, 9 Apr 2008 22:57:25 +0200 (CEST)

> This is the final part of the ADSL-optimizer patch, which is the real
> "holy grail" of packet scheduling on ADSL/ATM lines. (Referring to
> Wondershaper claim of the "holy grail".)

I think, sans the very minor macro and header issues mentioned,
Jesper's changes should be added if they haven't been already.

They look totally fine to me, and this stuff does not preclude
doing things in the kernel in the future at all.

Thanks.
