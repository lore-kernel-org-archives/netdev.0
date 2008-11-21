From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/10] x86: add Kconfig entry for DMA-API debugging
Date: Fri, 21 Nov 2008 15:18:57 -0800 (PST)
Message-ID: <20081121.151857.104010187.davem@davemloft.net>
References: <1227284770-19215-1-git-send-email-joerg.roedel@amd.com>
	<1227284770-19215-2-git-send-email-joerg.roedel@amd.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@redhat.com, tglx@linutronix.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, iommu@lists.linux-foundation.org
To: joerg.roedel@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40105
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752664AbYKUXS5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 18:18:57 -0500
In-Reply-To: <1227284770-19215-2-git-send-email-joerg.roedel@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joerg Roedel <joerg.roedel@amd.com>
Date: Fri, 21 Nov 2008 17:26:01 +0100

> Impact: adds a new Kconfig option
> 
> Signed-off-by: Joerg Roedel <joerg.roedel@amd.com>

This definitely should be generic code, rather than something
tucked away in x86 platform code.
