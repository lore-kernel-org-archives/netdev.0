From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/8] s390: print correct level for HiperSockets devices
Date: Wed, 20 Jun 2007 19:13:17 -0400
Message-ID: <4679B48D.5050200@garzik.org>
References: <20070620104817.GA2627@de.ibm.com> <20070620105518.GA9454@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Frank Pavlic <fpavlic@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45598 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756645AbXFTXNW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2007 19:13:22 -0400
In-Reply-To: <20070620105518.GA9454@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Frank Pavlic wrote:
> From: Ursula Braun <braunu@de.ibm.com>
> 
> For real HiperSockets the EBCDIC-ASCII conversion is not necessary.
> This is only needed for z/VM GuestLAN devices.
> 
> Signed-off-by: Ursula Braun <braunu@de.ibm.com>
> Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>
> ---
>  drivers/s390/net/qeth_main.c |   20 +++++++++++---------
>  1 files changed, 11 insertions(+), 9 deletions(-)

applied 1-8 to #upstream-fixes


