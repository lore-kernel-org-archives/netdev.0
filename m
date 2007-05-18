From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/3] ibm_emac: fix section mismatch warnings
Date: Thu, 17 May 2007 20:45:37 -0400
Message-ID: <464CF731.6030508@garzik.org>
References: <20070516185737.GA14704@gate.ebshome.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-embedded@ozlabs.org
To: ebs@ebshome.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43542 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755450AbXERApk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2007 20:45:40 -0400
In-Reply-To: <20070516185737.GA14704@gate.ebshome.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eugene Surovegin wrote:
> Fix "Section mismatch" warnings
> 
> Signed-off-by: Eugene Surovegin <ebs@ebshome.net>
> 
> ---
>  drivers/net/ibm_emac/ibm_emac_mal.c   |    3 +--
>  drivers/net/ibm_emac/ibm_emac_mal.h   |    3 +--
>  drivers/net/ibm_emac/ibm_emac_rgmii.c |    2 +-
>  drivers/net/ibm_emac/ibm_emac_rgmii.h |    2 +-
>  drivers/net/ibm_emac/ibm_emac_tah.c   |    2 +-
>  drivers/net/ibm_emac/ibm_emac_tah.h   |    2 +-
>  drivers/net/ibm_emac/ibm_emac_zmii.c  |    2 +-
>  drivers/net/ibm_emac/ibm_emac_zmii.h  |    2 +-
>  8 files changed, 8 insertions(+), 10 deletions(-)

applied 1-3

Please fix your incorrect Mail-Followup-To headers.  They cause mailers 
to NOT direct replies to you, and CC lists, which is contra to normal 
LKML behavior.


