From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/3] qlge: Relax alignment on TX harware queue.
Date: Thu, 11 Jun 2009 02:37:14 -0700 (PDT)
Message-ID: <20090611.023714.170488752.davem@davemloft.net>
References: <1244684975-10211-1-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54293
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759079AbZFKJhM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 05:37:12 -0400
In-Reply-To: <1244684975-10211-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Wed, 10 Jun 2009 18:49:33 -0700

> The alignment was on size of queue boundary, but the hardware
> only requires 4-byte alignment.
> 
> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>

Applied.
