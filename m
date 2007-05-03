From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ethtool: Add 2.5G support
Date: Thu, 03 May 2007 07:11:03 -0400
Message-ID: <4639C347.9000303@garzik.org>
References: <1178068303.4820.35.camel@dell> <1178177230.4909.63.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38880 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752854AbXECLLH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2007 07:11:07 -0400
In-Reply-To: <1178177230.4909.63.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Chan wrote:
> Add 2.5G Serdes support to ethtool user program and ethtool.8 man
> page.  The missing pause bits are also added to keep ethtool-copy.h
> in sync with the kernel's version.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

looks good at first glance.  will queue, and apply soon


