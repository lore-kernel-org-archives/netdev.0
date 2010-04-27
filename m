From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] cxgb4: parse the VPD instead of relying
 on a static VPD layout
Date: Tue, 27 Apr 2010 15:46:49 -0700 (PDT)
Message-ID: <20100427.154649.257500702.davem@davemloft.net>
References: <1272407056-11699-1-git-send-email-dm@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dm@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46814
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757293Ab0D0Wqo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 18:46:44 -0400
In-Reply-To: <1272407056-11699-1-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dimitris Michailidis <dm@chelsio.com>
Date: Tue, 27 Apr 2010 15:24:15 -0700

> Some boards' VPDs contain additional keywords or have longer serial numbers,
> meaning the keyword locations are variable.  Ditch the static layout and
> use the pci_vpd_* family of functions to parse the VPD instead.
> 
> Signed-off-by: Dimitris Michailidis <dm@chelsio.com>

Applied.
