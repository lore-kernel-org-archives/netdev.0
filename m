From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.21.5] 8139cp: dev->tx_timeout
Date: Mon, 02 Jul 2007 08:39:18 -0400
Message-ID: <4688F1F6.70803@garzik.org>
References: <OF0C14C62A.671A9095-ONC2257307.0035124F-C2257307.00396C0B@stonesoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mika.Lansirinne@stonesoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51150 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755260AbXGBMjU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2007 08:39:20 -0400
In-Reply-To: <OF0C14C62A.671A9095-ONC2257307.0035124F-C2257307.00396C0B@stonesoft.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mika.Lansirinne@stonesoft.com wrote:
> This patch implements the missing dev->tx_timeout for 8139cp driver
> 
> Signed-off-by: Mika Lansirinne <mika.lansirinne@stonesoft.com>

does not seem to apply to current kernel.  please resend against 
netdev-2.6.git#upstream or 2.6.22-rc7.


