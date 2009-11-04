From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] em_meta: avoid one dev_put()
Date: Wed, 04 Nov 2009 05:23:41 -0800 (PST)
Message-ID: <20091104.052341.167452135.davem@davemloft.net>
References: <4AF0A2E9.1080505@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60337
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756026AbZKDNXQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 08:23:16 -0500
In-Reply-To: <4AF0A2E9.1080505@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 03 Nov 2009 22:38:49 +0100

> Another rcu conversion to avoid one dev_hold()/dev_put() pair
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
