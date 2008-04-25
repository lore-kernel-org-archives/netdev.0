From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.26 1/5]S2io: Removed receive buffer replenishment
 tasklet
Date: Fri, 25 Apr 2008 01:48:19 -0400
Message-ID: <481170A3.6070803@garzik.org>
References: <Pine.GSO.4.10.10804231329010.10279-100000@guinness>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, support@neterion.com
To: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46825 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753402AbYDYFsV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Apr 2008 01:48:21 -0400
In-Reply-To: <Pine.GSO.4.10.10804231329010.10279-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sreenivasa Honnur wrote:
> - Removed receive buffer replenishment tasklet s2io_tasklet and instead 
>   allocating the receive buffers in either the interrupt handler (no napi) 
>   or the napi handler (napi enabled).
> 
> Signed-off-by: Surjit Reang <surjit.reang@neterion.com>
> Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
> Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>

applied 1-2 of 5


