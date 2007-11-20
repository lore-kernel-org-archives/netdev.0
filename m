From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tun: use iov_length()
Date: Mon, 19 Nov 2007 22:47:07 -0800 (PST)
Message-ID: <20071119.224707.33968344.davem@davemloft.net>
References: <20071117135500.GA14691@APFDCB5C>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vtun@office.satix.net, maxk@qualcomm.com
To: akinobu.mita@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40573
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752526AbXKTGrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 01:47:08 -0500
In-Reply-To: <20071117135500.GA14691@APFDCB5C>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Akinobu Mita <akinobu.mita@gmail.com>
Date: Sat, 17 Nov 2007 22:55:00 +0900

> Use iov_length() instead of tun's homemade iov_total().
> 
> Cc: Maxim Krasnyansky <maxk@qualcomm.com>
> Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>

Applied, thank you.
