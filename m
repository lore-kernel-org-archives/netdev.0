From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 2/3] qlge: Fix printk priority so chip fatal
 errors are always reported.
Date: Fri, 01 Jul 2011 17:36:34 -0700 (PDT)
Message-ID: <20110701.173634.932675372918593722.davem@davemloft.net>
References: <1308855049.6688.19.camel@Joe-Laptop>
	<1309464127-14797-2-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jitendra.kalsaria@qlogic.com,
	ameen.rahman@qlogic.com
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51352 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751168Ab1GBAgi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2011 20:36:38 -0400
In-Reply-To: <1309464127-14797-2-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Thu, 30 Jun 2011 13:02:06 -0700

> From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
> 
> Precedence of the printk should be at higher level so chip fatal
> errors are always reported.
> 
> Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>

Applied.
