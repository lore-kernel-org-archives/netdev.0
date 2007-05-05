From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 7/11][TG3]: Eliminate the TG3_FLAG_5701_REG_WRITE_BUG
 flag.
Date: Fri, 04 May 2007 20:36:48 -0400
Message-ID: <463BD1A0.2090702@garzik.org>
References: <1178326457.4859.23.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53220 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161630AbXEEAgv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2007 20:36:51 -0400
In-Reply-To: <1178326457.4859.23.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Chan wrote:
> [TG3]: Eliminate the TG3_FLAG_5701_REG_WRITE_BUG flag.
> 
> This patch removes the use of the TG3_FLAG_5701_REG_WRITE_BUG flag.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

ACK, though the patch description is a bit unclear /why/ the flag can be 
eliminated -- even though it is certainly clear from reading the patch 
that this is a logical simplification.


