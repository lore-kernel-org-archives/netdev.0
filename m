From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] Fix typo in new EMAC driver.
Date: Wed, 03 Oct 2007 13:51:10 -0400
Message-ID: <4703D68E.9010000@garzik.org>
References: <20071002120107.GA21847@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, Josh Boyer <jwboyer@linux.vnet.ibm.com>,
	netdev <netdev@vger.kernel.org>
To: "Valentine Barshak (by way of Josh Boyer <jwboyer@linux.vnet.ibm.com>)"
	<vbarshak@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:32790 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755242AbXJCRvU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Oct 2007 13:51:20 -0400
In-Reply-To: <20071002120107.GA21847@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Valentine Barshak (by way of Josh Boyer <jwboyer@linux.vnet.ibm.com>) wrote:
> Fix an obvious typo in emac_xmit_finish.
> 
> Signed-off-by: Valentine Barshak <vbarshak@ru.mvista.com>
> ---
>  drivers/net/ibm_newemac/core.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)

applied


