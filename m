From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH v4] PHYLIB: Add 1000Base-X support for Broadcom bcm5482
Date: Sun, 18 May 2008 13:37:52 -0500
Message-ID: <7A99F3E8-ADA1-431C-ADDB-FBC652C05E5C@freescale.com>
References: <Pine.LNX.4.55.0805170619390.4049@cliff.in.clinika.pl>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Nate Case <ncase@xes-inc.com>,
	netdev@vger.kernel.org
To: "Maciej W. Rozycki" <macro@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:45952 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754167AbYERSiN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 May 2008 14:38:13 -0400
In-Reply-To: <Pine.LNX.4.55.0805170619390.4049@cliff.in.clinika.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On May 17, 2008, at 00:40, Maciej W. Rozycki wrote:

> From: Nate Case <ncase@xes-inc.com>
>
> Configure the BCM5482S secondary SerDes for 1000Base-X mode when the
> appropriate dev_flags are passed in to phy_connect().  This is
> needed when the PHY is used for fiber and backplane connections.
>
> Signed-off-by: Nate Case <ncase@xes-inc.com>
> Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>

Acked-by: Andy Fleming <afleming@freescale.com>

