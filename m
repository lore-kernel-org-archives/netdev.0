From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/20][BNX2]: Block MII access when ifdown.
Date: Wed, 02 May 2007 02:58:27 -0400
Message-ID: <46383693.5080506@garzik.org>
References: <1178068341.4820.37.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55926 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161740AbXEBG6b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2007 02:58:31 -0400
In-Reply-To: <1178068341.4820.37.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Chan wrote:
> [BNX2]: Block MII access when ifdown.
> 
> The device may be in D3hot state and should not allow MII register
> access.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

ACK 1-2


