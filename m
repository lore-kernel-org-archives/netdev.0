From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH alt] sky2: Make sure both ports initialize correctly
Date: Tue, 15 Sep 2009 02:50:42 -0700 (PDT)
Message-ID: <20090915.025042.171980470.davem@davemloft.net>
References: <4AAD7B86.6060300@ring3k.org>
	<20090914092229.31490f45@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mikem@ring3k.org, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59090
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751620AbZIOJuZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2009 05:50:25 -0400
In-Reply-To: <20090914092229.31490f45@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Mon, 14 Sep 2009 09:22:29 -0700

> Sorry Mike, I sent you off the wrong way. The following is simpler and the
> second port is diffrent enough in setup (because of NAPI), that the
> following is simpler.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
