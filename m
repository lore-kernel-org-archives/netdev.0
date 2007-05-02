From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 5/20][BNX2]: Save PCI state during suspend.
Date: Wed, 02 May 2007 03:08:59 -0400
Message-ID: <4638390B.2020607@garzik.org>
References: <1178068462.4820.41.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55994 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754907AbXEBHJC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2007 03:09:02 -0400
In-Reply-To: <1178068462.4820.41.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Chan wrote:
> [BNX2]: Save PCI state during suspend.
> 
> This is needed to save the MSI state which will be lost during
> suspend.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

ACK


