From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net-caif: Added missing lock validator
 constants
Date: Mon, 07 Jun 2010 01:01:32 -0700 (PDT)
Message-ID: <20100607.010132.123978690.davem@davemloft.net>
References: <1275761704-8758-1-git-send-email-alex.lorca@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sjur.brandeland@stericsson.com, netdev@vger.kernel.org
To: alex.lorca@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42401
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932445Ab0FGIBW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 04:01:22 -0400
In-Reply-To: <1275761704-8758-1-git-send-email-alex.lorca@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alex Lorca <alex.lorca@gmail.com>
Date: Sat,  5 Jun 2010 18:15:04 +0000

> CAIF is using "xxx-AF_MAX" strings for the lock validator. It should use
> its own strings.
> 
> Signed-off-by: Alex Lorca <alex.lorca@gmail.com>

Applied, thank you.
