From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] forcedeth: msi interrupt fix
Date: Sat, 07 Feb 2009 00:26:07 -0800 (PST)
Message-ID: <20090207.002607.141801104.davem@davemloft.net>
References: <498C8F1C.2000108@nvidia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: manfred@colorfullife.com, jgarzik@pobox.com, akpm@osdl.org,
	netdev@vger.kernel.org
To: aabdulla@nvidia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35969
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753463AbZBGI0L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 03:26:11 -0500
In-Reply-To: <498C8F1C.2000108@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ayaz Abdulla <aabdulla@nvidia.com>
Date: Fri, 06 Feb 2009 14:27:24 -0500

> This patch fixes an issue with the suspend/resume cycle with msi
> interrupts. See bugzilla number 10487 for more details. The fix is to
> re-setup a private msi pci config offset field.
> 
> Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>

Applied to net-next-2.6
