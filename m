From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/1] /drivers/net/r6040.c: bad use of round_jiffies()
 ???
Date: Wed, 11 Jun 2008 22:50:48 -0400
Message-ID: <48508F08.7040009@garzik.org>
References: <20080515212624.D56371C00093@mwinf2723.orange.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux <linux-kernel@vger.kernel.org>,
	florian.fainelli@telecomint.eu, netdev@vger.kernel.org
To: Christophe Jaillet <christophe.jaillet@wanadoo.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45526 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755481AbYFLCuw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2008 22:50:52 -0400
In-Reply-To: <20080515212624.D56371C00093@mwinf2723.orange.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christophe Jaillet wrote:
> From: Christophe Jaillet <christophe.jaillet@wanadoo.fr>
> 
> Hi, here is a patch against linux/drivers/net/r6040.c.
> 
> Compared to other places in the kernel, I think that this driver misuses
> the function round_jiffies.
> 
> 
> Note: this patch is based on 'linux-2.6.25.tar.bz2'
> 
> Signed-off-by: Christophe Jaillet <christophe.jaillet@wanadoo.fr>

applied



