From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] Add support for configuring the PHY connection interface
Date: Tue, 14 Nov 2006 10:30:19 -0500
Message-ID: <4559E10B.2030905@pobox.com>
References: <Pine.LNX.4.61.0611080009010.6936@ld0175-tx32.am.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:16064 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S965983AbWKNPaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Nov 2006 10:30:21 -0500
To: Andy Fleming <afleming@freescale.com>
In-Reply-To: <Pine.LNX.4.61.0611080009010.6936@ld0175-tx32.am.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Fleming wrote:
> Most PHYs connect to an ethernet controller over a GMII or MII
> interface.  However, a growing number are connected over
> different interfaces, such as RGMII or SGMII.
> 
> The ethernet driver will tell the PHY what type of connection it
> is by setting it manually, or passing it in through phy_connect
> (or phy_attach).
> 
> Changes include:
> * Updates to documentation
> * Updates to other PHY Lib consumers
> * Changes to PHY Lib to add interface support
> * Some minor changes to whitespace in phy.h
> * interface values now passed to gianfar
> 
> Signed-off-by: Andrew Fleming <afleming@freescale.com>

ACK technical content, but



Applying 'Add support for configuring the PHY connection interface'

error: patch failed: arch/powerpc/sysdev/fsl_soc.c:211
error: arch/powerpc/sysdev/fsl_soc.c: patch does not apply
