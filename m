From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 2.6.25 typhoon_resume - remove call to start_queue
Date: Sun, 20 Apr 2008 22:57:26 -0700 (PDT)
Message-ID: <20080420.225726.145290117.davem@davemloft.net>
References: <20080421044415.GB15080@colo.lackof.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, dave@thedillows.org, netdev@vger.kernel.org
To: grundler@parisc-linux.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52202
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751703AbYDUF53 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 01:57:29 -0400
In-Reply-To: <20080421044415.GB15080@colo.lackof.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Grundler <grundler@parisc-linux.org>
Date: Sun, 20 Apr 2008 22:44:15 -0600

> Comments/code in netif_device_attach() suggest it is restarting the queue.
> Thus, typhoon_resume() doesn't need to call start_queue().
> 
> Signed-off-by: Grant Grundler <grundler@parisc-linux.org>

Acked-by: David S. Miller <davem@davemloft.net>
