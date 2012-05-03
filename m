From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: fix handling single MSIX mode for
 57710/57711
Date: Wed, 02 May 2012 20:04:15 -0400 (EDT)
Message-ID: <20120502.200415.1592177809882949817.davem@davemloft.net>
References: <1335957393-21804-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37738 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752525Ab2ECAES (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 20:04:18 -0400
In-Reply-To: <1335957393-21804-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry Kravkov" <dmitry@broadcom.com>
Date: Wed, 2 May 2012 14:16:33 +0300

> commit 30a5de7723a8a4211be02e94236e9167a424fd07 added
> ability to use single MSI-X vector, but lack proper
> handling for 57710/57711 HW
> 
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied, thanks.
