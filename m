From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] Add support for Marvell 88e1111S and 88e1145
Date: Tue, 14 Nov 2006 10:31:32 -0500
Message-ID: <4559E154.3020404@pobox.com>
References: <Pine.LNX.4.61.0611080010310.6936@ld0175-tx32.am.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:25536 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S966004AbWKNPbd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Nov 2006 10:31:33 -0500
To: Andy Fleming <afleming@freescale.com>
In-Reply-To: <Pine.LNX.4.61.0611080010310.6936@ld0175-tx32.am.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Fleming wrote:
> This patch requires the new support for configurable PHY
> interfaces.
> 
> Changes include:
> * New support for 88e1145
> * New support for 88e111s
> * Fixing 88e1101 driver to not match non-88e1101 PHYs
> * Increases in feature support across Marvell PHY product line
> * Fixes a bunch of whitespace issues found by Lindent
> 
> Signed-off-by: Andrew Fleming <afleming@freescale.com>

applied.

As your email subject line is copied directly into the kernel changelog, 
please indicate the area of the kernel you are patching as a prefix 
(read http://linux.yyz.us/patch-format.html)  Example:

Subject: PHY: Add support for Marvell 88e1111S and 88e1145


