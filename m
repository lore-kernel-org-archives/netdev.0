From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] enic: Support newer version of firmware
 devcmd CMD_MCPU_FW_INFO
Date: Mon, 14 Mar 2011 14:49:40 -0700 (PDT)
Message-ID: <20110314.144940.229742493.davem@davemloft.net>
References: <20110309013530.17378.56666.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vkolluri@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42822
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751983Ab1CNVtC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 17:49:02 -0400
In-Reply-To: <20110309013530.17378.56666.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>
Date: Tue, 08 Mar 2011 17:35:30 -0800

> From: Vasanthy Kolluri <vkolluri@cisco.com>
> 
> This patch provides support to the newer version of firmware devcmd CMD_MCPU_FW_INFO
> that returns additional information (ASIC type and revision) about the underlying hardware.
> This knowledge is required by the driver to implement any hardware specific features.
> 
> Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
> Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
> Signed-off-by: David Wang <dwang2@cisco.com>

Applied, thanks.
