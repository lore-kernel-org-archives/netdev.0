From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] tg3: use <linux/io.h> and <linux/uaccess.h>
 instead <asm/io.h> and <asm/uaccess.h>
Date: Sun, 27 Mar 2011 18:38:43 -0700 (PDT)
Message-ID: <20110327.183843.116365744.davem@davemloft.net>
References: <1301193753-10045-1-git-send-email-martinez.javier@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, mchan@broadcom.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: martinez.javier@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54531
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753235Ab1C1BjV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2011 21:39:21 -0400
In-Reply-To: <1301193753-10045-1-git-send-email-martinez.javier@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Javier Martinez Canillas <martinez.javier@gmail.com>
Date: Sun, 27 Mar 2011 04:42:31 +0200

> It is proper style to include linux/foo.h instead asm/foo.h if both exist
> 
> Signed-off-by: Javier Martinez Canillas <martinez.javier@gmail.com>

Applied.
