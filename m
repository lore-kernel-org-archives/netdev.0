From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] NET: sungem, use spin_trylock_irqsave
Date: Wed, 04 Nov 2009 08:37:38 -0800 (PST)
Message-ID: <20091104.083738.170517131.davem@davemloft.net>
References: <1257350818-4194-1-git-send-email-jirislaby@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jirislaby@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49545
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756888AbZKDQhN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 11:37:13 -0500
In-Reply-To: <1257350818-4194-1-git-send-email-jirislaby@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Slaby <jirislaby@gmail.com>
Date: Wed,  4 Nov 2009 17:06:58 +0100

> Use spin_trylock_irqsave instead of open-coded
> local_irq_save+spin_trylock.
> 
> Signed-off-by: Jiri Slaby <jirislaby@gmail.com>

Applied, thanks.
