From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: only enable Vaux if capable of wakeup
Date: Thu, 03 Sep 2009 20:10:43 -0700 (PDT)
Message-ID: <20090903.201043.192001662.davem@davemloft.net>
References: <4A9928C9.7000907@ring3k.org>
	<200908311158.57972.rene.mayrhofer@gibraltar.at>
	<20090903091625.2e6aff91@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rene.mayrhofer@gibraltar.at, mikem@ring3k.org,
	netdev@vger.kernel.org, leitner@esys.at
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51035
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932700AbZIDDK2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 23:10:28 -0400
In-Reply-To: <20090903091625.2e6aff91@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Thu, 3 Sep 2009 09:16:25 -0700

> While perusing vendor driver, I saw that it did not enable the Vaux
> power unless device was able to wake from lan for D3cold.
> This might help for Rene's power issue.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
