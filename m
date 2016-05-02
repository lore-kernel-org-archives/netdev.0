From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/3] drivers: net: xgene: fix: Get channel number
 from device binding
Date: Mon, 02 May 2016 16:48:18 -0400 (EDT)
Message-ID: <20160502.164818.1876590443775185144.davem@davemloft.net>
References: <1461953415-9741-1-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, patches@apm.com
To: isubramanian@apm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36302 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753488AbcEBUsX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 16:48:23 -0400
In-Reply-To: <1461953415-9741-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Iyappan Subramanian <isubramanian@apm.com>
Date: Fri, 29 Apr 2016 11:10:12 -0700

> This patch set adds 'channel' property to get ethernet to CPU channel number,
> thus decoupling the Linux driver from static resource selection.
> 
> v2: Address review comments from v1
> - removed irq reference from Linux driver
> - added 'channel' property to get ethernet to CPU channel number
> 
> v1:
> - Initial version
> 
> Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>

Series applied, thanks.
