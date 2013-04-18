From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] fec: Remove unneeded asm header files
Date: Thu, 18 Apr 2013 14:56:45 -0400 (EDT)
Message-ID: <20130418.145645.1884327260939032473.davem@davemloft.net>
References: <1366289682-3889-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gerg@uclinux.org, netdev@vger.kernel.org
To: fabio.estevam@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55457 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750958Ab3DRS4r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 14:56:47 -0400
In-Reply-To: <1366289682-3889-1-git-send-email-fabio.estevam@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>
Date: Thu, 18 Apr 2013 09:54:39 -0300

> There is nothing in the driver that requires <asm/coldfire.h> and
> <asm/mcfsim.h>.
> 
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Applied.
