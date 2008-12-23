From: David Miller <davem@davemloft.net>
Subject: Re: [patch]prepare usb net drivers for addition of status as a
 parameter
Date: Mon, 22 Dec 2008 19:32:30 -0800 (PST)
Message-ID: <20081222.193230.22129424.davem@davemloft.net>
References: <200812181629.52574.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: oliver@neukum.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42170
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753554AbYLWDce (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2008 22:32:34 -0500
In-Reply-To: <200812181629.52574.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum <oliver@neukum.org>
Date: Thu, 18 Dec 2008 16:29:51 +0100

> USB is going to switch the signature of the callbacks to
> void callback(struct urb *urb, int status)
> This patch will ease the transition.
> 
> Signed-off-by: Oliver Neukum <oneukum@suse.de>

Applied to net-next-2.6, thanks Oliver.
