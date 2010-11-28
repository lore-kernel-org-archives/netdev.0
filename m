From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] bnx2: Remove config access to
 non-standard registers
Date: Sun, 28 Nov 2010 10:49:42 -0800 (PST)
Message-ID: <20101128.104942.48499452.davem@davemloft.net>
References: <1290642535-20293-1-git-send-email-mchan@broadcom.com>
	<1290642535-20293-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36581
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753866Ab0K1StP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Nov 2010 13:49:15 -0500
In-Reply-To: <1290642535-20293-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 24 Nov 2010 15:48:55 -0800

> In KVM passthrough mode, the driver may not have config access to
> non-standard registers.  The BNX2_PCICFG_MISC_CONFIG config register
> access to setup mailbox swapping can be done using MMIO.
> 
> Update version to 2.0.20.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
