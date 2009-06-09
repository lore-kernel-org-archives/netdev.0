From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 1/15]: bluetooth: Kill skb_frags_no(), unused.
Date: Tue, 09 Jun 2009 17:27:45 +0200
Message-ID: <1244561265.3068.18.camel@localhost.localdomain>
References: <20090609.050149.48753449.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:46078 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751475AbZFIP1p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 11:27:45 -0400
In-Reply-To: <20090609.050149.48753449.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

> Furthermore, it twiddles with the details of SKB list handling
> directly, which we're trying to eliminate.

seems to be unused anyway ;)

> Signed-off-by: David S. Miller <davem@davemloft.net>

Acked-by: Marcel Holtmann <marcel@holtmann.org>

Regards

Marcel


