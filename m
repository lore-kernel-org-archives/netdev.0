From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: qmi_wwan: add support for Cinterion PXS8 and PHS8
Date: Thu, 13 Feb 2014 18:23:54 -0500 (EST)
Message-ID: <20140213.182354.616365670949999498.davem@davemloft.net>
References: <1392216914-11520-1-git-send-email-aleksander@aleksander.es>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bjorn@mork.no, netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	hans-christoph.schemmel@gemalto.com,
	christian.schmiedl@gemalto.com, nicolaus.colberg@gemalto.com,
	david.mccullough@accelecon.com
To: aleksander@aleksander.es
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51308 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752043AbaBMXX5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 18:23:57 -0500
In-Reply-To: <1392216914-11520-1-git-send-email-aleksander@aleksander.es>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aleksander Morgado <aleksander@aleksander.es>
Date: Wed, 12 Feb 2014 15:55:14 +0100

> When the PXS8 and PHS8 devices show up with PID 0x0053 they will expose both a
> QMI port and a WWAN interface.
> 
> CC: Hans-Christoph Schemmel <hans-christoph.schemmel@gemalto.com>
> CC: Christian Schmiedl <christian.schmiedl@gemalto.com>
> CC: Nicolaus Colberg <nicolaus.colberg@gemalto.com>
> CC: David McCullough <david.mccullough@accelecon.com>
> Signed-off-by: Aleksander Morgado <aleksander@aleksander.es>

Applied.
