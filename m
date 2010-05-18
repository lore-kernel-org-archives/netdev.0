From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] [PPP] cleanup: remove pppoe_ioctl()
 declaration.
Date: Mon, 17 May 2010 22:58:30 -0700 (PDT)
Message-ID: <20100517.225830.67918065.davem@davemloft.net>
References: <AANLkTinUFYCHp-9qw3bHIqolKrS0X33FjFmDsdS2XWec@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58183
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756596Ab0ERF6V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 01:58:21 -0400
In-Reply-To: <AANLkTinUFYCHp-9qw3bHIqolKrS0X33FjFmDsdS2XWec@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <ramirose@gmail.com>
Date: Wed, 12 May 2010 08:37:36 +0300

> Hi,
>   - This patch removes pppoe_ioctl()  declaration in
> drivers/net/pppoe.c as it is unneeded.
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Applied.
