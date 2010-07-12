From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ac3200: fix error path
Date: Sun, 11 Jul 2010 18:15:52 -0700 (PDT)
Message-ID: <20100711.181552.91332689.davem@davemloft.net>
References: <1278678489-7053-1-git-send-email-segooon@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, joe@perches.com,
	netdev@vger.kernel.org
To: segooon@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33100
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752608Ab0GLBPh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jul 2010 21:15:37 -0400
In-Reply-To: <1278678489-7053-1-git-send-email-segooon@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kulikov Vasiliy <segooon@gmail.com>
Date: Fri,  9 Jul 2010 16:28:09 +0400

> Do not call free_irq() if request_irq() failed.
> 
> Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>

Applied.
