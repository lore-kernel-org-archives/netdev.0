From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] gianfar: kill unused header
Date: Mon, 16 Jul 2007 18:29:55 -0400
Message-ID: <469BF163.5040307@garzik.org>
References: <Pine.LNX.4.64.0707130037570.16069@blarg.am.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:37275 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762473AbXGPW35 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2007 18:29:57 -0400
In-Reply-To: <Pine.LNX.4.64.0707130037570.16069@blarg.am.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kumar Gala wrote:
> A long time ago we used OCP with the gianfar driver.  Eventually when
> we kill arch/ppc including this will cause issues so lets just kill it now.
> 
> Signed-off-by: Kumar Gala <galak@kernel.crashing.org>

applied


