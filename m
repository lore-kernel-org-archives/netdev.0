From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 13/20][BNX2]: Put MII register offsets in the bnx2 struct.
Date: Wed, 02 May 2007 03:12:36 -0400
Message-ID: <463839E4.60103@garzik.org>
References: <1178068549.4820.49.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56047 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754919AbXEBHMj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2007 03:12:39 -0400
In-Reply-To: <1178068549.4820.49.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Chan wrote:
> [BNX2]: Put MII register offsets in the bnx2 struct.
> 
> The 5709 Serdes device uses non-standard MII register offsets.  This
> re-structuring will make it easier to support 5709 Serdes.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

ACK patches 12-13


