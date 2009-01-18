From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.29] myri10ge: don't forget pci_disable_device()
Date: Sat, 17 Jan 2009 23:06:38 -0800 (PST)
Message-ID: <20090117.230638.176076290.davem@davemloft.net>
References: <49722307.4010109@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: brice@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37555
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755966AbZARHGh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2009 02:06:37 -0500
In-Reply-To: <49722307.4010109@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brice Goglin <brice@myri.com>
Date: Sat, 17 Jan 2009 19:27:19 +0100

> Don't forget to call pci_disable_device() in myri10ge_remove()
> and when myri10ge_probe() fails.
> 
> By the way, update the copyright years.
> 
> Signed-off-by: Brice Goglin <brice@myri.com>

Applied.
