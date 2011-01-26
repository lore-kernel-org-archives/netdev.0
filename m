From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] bnx2: Eliminate AER error messages on systems
 not supporting it
Date: Wed, 26 Jan 2011 14:26:35 -0800 (PST)
Message-ID: <20110126.142635.59692241.davem@davemloft.net>
References: <1296029691-3591-1-git-send-email-mchan@broadcom.com>
	<1296029691-3591-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: leitao@linux.vnet.ibm.com, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44060
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754355Ab1AZW0B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jan 2011 17:26:01 -0500
In-Reply-To: <1296029691-3591-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 26 Jan 2011 00:14:51 -0800

> On PPC for example, AER is not supported and we see unnecessary AER
> error message without this patch:
> 
> bnx2 0003:01:00.1: pci_cleanup_aer_uncorrect_error_status failed 0xfffffffb
> 
> Reported-by: Breno Leitao <leitao@linux.vnet.ibm.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
