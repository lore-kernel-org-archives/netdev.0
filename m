From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5] forcedeth: recover error support
Date: Sat, 07 Feb 2009 00:26:19 -0800 (PST)
Message-ID: <20090207.002619.95147013.davem@davemloft.net>
References: <498C8F1F.2060005@nvidia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, manfred@colorfullife.com, akpm@osdl.org,
	netdev@vger.kernel.org
To: aabdulla@nvidia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35982
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752537AbZBGI0X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 03:26:23 -0500
In-Reply-To: <498C8F1F.2060005@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ayaz Abdulla <aabdulla@nvidia.com>
Date: Fri, 06 Feb 2009 14:27:27 -0500

> This patch adds another type of recoverable error to the driver. It also
> modifies the sequence for recovery to include a mac reset and clearing
> of interrupts.
> 
> Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>

Applied to net-next-2.6
