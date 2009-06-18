From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Keep index within tab_unreach[]
Date: Wed, 17 Jun 2009 19:03:20 -0700 (PDT)
Message-ID: <20090617.190320.149874266.davem@davemloft.net>
References: <4A37E715.4060504@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50535
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757287AbZFRCDQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 22:03:16 -0400
In-Reply-To: <4A37E715.4060504@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Tue, 16 Jun 2009 20:40:21 +0200

> Ensure that index `code' remains within array tab_unreach[]
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Applied.
