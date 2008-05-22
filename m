From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH v4] PHYLIB: Add 1000Base-X support for Broadcom bcm5482
Date: Thu, 22 May 2008 07:09:33 -0400
Message-ID: <4835546D.5080706@pobox.com>
References: <Pine.LNX.4.55.0805170619390.4049@cliff.in.clinika.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Nate Case <ncase@xes-inc.com>, netdev@vger.kernel.org
To: "Maciej W. Rozycki" <macro@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48275 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762308AbYEVLJh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 07:09:37 -0400
In-Reply-To: <Pine.LNX.4.55.0805170619390.4049@cliff.in.clinika.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Maciej W. Rozycki wrote:
> From: Nate Case <ncase@xes-inc.com>
> 
> Configure the BCM5482S secondary SerDes for 1000Base-X mode when the
> appropriate dev_flags are passed in to phy_connect().  This is
> needed when the PHY is used for fiber and backplane connections.
> 
> Signed-off-by: Nate Case <ncase@xes-inc.com>
> Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
> ---
> Jeff,
> 
>  I have removed unnecessary "inline" annotations and made a few formatting
> adjustments.  I hope Nate agrees with these changes.  Please apply.

applied this and Kconfig patch


