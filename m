From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] sky2: allow mac to come from dt
Date: Mon, 10 Mar 2014 15:40:53 -0400 (EDT)
Message-ID: <20140310.154053.112406994898885984.davem@davemloft.net>
References: <1394254793-19228-1-git-send-email-tharvey@gateworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, grant.likely@linaro.org,
	robh+dt@kernel.org
To: tharvey@gateworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46644 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752418AbaCJTk4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 15:40:56 -0400
In-Reply-To: <1394254793-19228-1-git-send-email-tharvey@gateworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tim Harvey <tharvey@gateworks.com>
Date: Fri,  7 Mar 2014 20:59:53 -0800

> The driver reads the mac address from the device registers which would
> need to have been programmed by the bootloader.  This patch adds
> the ability to pull the mac from devicetree via the pci device dt node.
> 
> Signed-off-by: Tim Harvey <tharvey@gateworks.com>
> Cc: netdev@vger.kernel.org
> Cc: devicetree@vger.kernel.org
> Cc: Grant Likely <grant.likely@linaro.org>
> Cc: Rob Herring <robh+dt@kernel.org>
> 
> Changes since v2:
>  - eliminated use of stack tmpaddr per feedback
> 
> Changes since v1:
>  - simplified based on feedback
>  - fixed formatting

Applied to net-next, thanks.
