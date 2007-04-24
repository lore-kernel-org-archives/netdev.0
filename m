From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH v2 1/7] phylib: add RGMII-ID interface mode definition
Date: Tue, 24 Apr 2007 14:02:33 -0400
Message-ID: <462E4639.3030400@pobox.com>
References: <20070413012557.4fe6eceb.kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kim Phillips <kim.phillips@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40339 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754335AbXDXSCf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Apr 2007 14:02:35 -0400
In-Reply-To: <20070413012557.4fe6eceb.kim.phillips@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kim Phillips wrote:
> The RGMII spec allows compliance for devices that implement an internal
> delay on TXC or RXC inside the transmitter.  This patch adds an RGMII_ID
> definition to support RGMII-ID devices in the phylib.
> 
> Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
> ---
> this 7 part series supercedes previous 2-set ucc_geth series submitted 10 apr 2007.
> please consider for 2.6.22
> 
>  include/linux/phy.h |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)

applied 1-7


