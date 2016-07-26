From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v7 00/12] drivers: net: xgene: Fix module
 crash and 1G hot-plug
Date: Mon, 25 Jul 2016 21:52:01 -0700 (PDT)
Message-ID: <20160725.215201.293002281412965878.davem@davemloft.net>
References: <1469491967-28627-1-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, patches@apm.com,
	linux@armlinux.org.uk
To: isubramanian@apm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52432 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753109AbcGZEwD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2016 00:52:03 -0400
In-Reply-To: <1469491967-28627-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Iyappan Subramanian <isubramanian@apm.com>
Date: Mon, 25 Jul 2016 17:12:35 -0700

> This patchset addresses the following issues,
> 
> 1. Fixes the kernel crash when the driver loaded as an kernel module
> 	- by fixing hardware cleanups and rearrange kernel API calls
> 
> 2. Hot-plug issue on the SGMII 1G interface
> 	- by adding a driver for MDIO management
> 
> Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
> Tested-by: Fushen Chen <fchen@apm.com>
> Tested-by: Toan Le <toanle@apm.com>

Series applied, thank you.
