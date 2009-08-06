From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] irda: Fix irda_getname() leak
Date: Thu, 06 Aug 2009 13:09:43 -0700 (PDT)
Message-ID: <20090806.130943.182768429.davem@davemloft.net>
References: <4A7AE0B8.8010600@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56558
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756600AbZHFUJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 16:09:34 -0400
In-Reply-To: <4A7AE0B8.8010600@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 06 Aug 2009 15:55:04 +0200

> irda_getname() can leak kernel memory to user.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied to net-2.6
