From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn/hysdn: Convert to kstrtoul_from_user
Date: Sun, 15 Apr 2012 00:21:25 -0400 (EDT)
Message-ID: <20120415.002125.1245643666941498950.davem@davemloft.net>
References: <1334446979-1177-1-git-send-email-peterhuewe@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: peterhuewe@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33910 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750740Ab2DOEVl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Apr 2012 00:21:41 -0400
In-Reply-To: <1334446979-1177-1-git-send-email-peterhuewe@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Huewe <peterhuewe@gmx.de>
Date: Sun, 15 Apr 2012 01:42:59 +0200

> This patch replaces the code for getting an number from a
> userspace buffer by a simple call to kstroul_from_user.
> This makes it easier to read and less error prone.
> 
> Signed-off-by: Peter Huewe <peterhuewe@gmx.de>

Applied to net-next, thanks a lot.
