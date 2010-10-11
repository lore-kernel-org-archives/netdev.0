From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2 net-next] bnx2: Enable AER on PCIE devices only
Date: Mon, 11 Oct 2010 16:12:58 -0700 (PDT)
Message-ID: <20101011.161258.183052620.davem@davemloft.net>
References: <1286494973-5115-1-git-send-email-mchan@broadcom.com>
	<1286494973-5115-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48248
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751716Ab0JKXMg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Oct 2010 19:12:36 -0400
In-Reply-To: <1286494973-5115-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 7 Oct 2010 16:42:53 -0700

> To prevent unnecessary error message.  pci_save_state() is also moved to
> the end of ->probe() so that all PCI config, including AER state, will be
> saved.
> 
> Update version to 2.0.18.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Reviewed-by: Benjamin Li <mchan@broadcom.com>

Applied.
