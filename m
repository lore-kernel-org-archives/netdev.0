From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND][PATCH 2/3] PPPoX/E: return ENOTTY on unknown ioctl
 requests
Date: Mon, 30 Jul 2007 17:48:44 -0700 (PDT)
Message-ID: <20070730.174844.133288731.davem@davemloft.net>
References: <20070729060435.GB27573@florz.florz.dyndns.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mostrows@earthlink.net, netdev@vger.kernel.org
To: florz@florz.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33313
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S934515AbXGaAso (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 20:48:44 -0400
In-Reply-To: <20070729060435.GB27573@florz.florz.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Zumbiehl <florz@florz.de>
Date: Sun, 29 Jul 2007 08:04:36 +0200

> here another patch for the PPPoX/E code that makes sure that ENOTTY is
> returned for unknown ioctl requests rather than 0 (and removes another
> unneeded initializer which I didn't bother creating a separate patch for).
> 
> Signed-off-by: Florian Zumbiehl <florz@florz.de>

Applied, thanks Florian.
