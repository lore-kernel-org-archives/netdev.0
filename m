From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: avoid wraparound for expired preferred lifetime
Date: Thu, 25 Jun 2009 20:10:16 -0700 (PDT)
Message-ID: <20090625.201016.67627705.davem@davemloft.net>
References: <20090625145550.GQ21357@jayr.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: me@jayr.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48338
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752699AbZFZDKL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2009 23:10:11 -0400
In-Reply-To: <20090625145550.GQ21357@jayr.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jens Rosenboom <me@jayr.de>
Date: Thu, 25 Jun 2009 16:55:50 +0200

> Avoid showing wrong high values when the preferred lifetime of an address
> is expired.
> 
> Signed-off-by: Jens Rosenboom <me@jayr.de>

Applied, thanks.
