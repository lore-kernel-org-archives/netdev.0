From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.17 1/2] bnx2: Fix bug in bnx2_nvram_write()
Date: Mon, 22 May 2006 14:48:22 -0400
Message-ID: <44720776.9010405@garzik.org>
References: <1148317309.4780.116.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:28058 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751129AbWEVSsZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 May 2006 14:48:25 -0400
To: Michael Chan <mchan@broadcom.com>
In-Reply-To: <1148317309.4780.116.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Chan wrote:
> Fix a bug in bnx2_nvram_write() caused by a counter variable not
> correctly incremented by 4.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

ACK patches 1-2


