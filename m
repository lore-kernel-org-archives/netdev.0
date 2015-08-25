From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sun4i-emac: Claim emac sram
Date: Tue, 25 Aug 2015 13:49:12 -0700 (PDT)
Message-ID: <20150825.134912.1446921736351472961.davem@davemloft.net>
References: <1440354698-11144-1-git-send-email-hdegoede@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maxime.ripard@free-electrons.com, jelle@vdwaa.nl,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linux-sunxi@googlegroups.com
To: hdegoede@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59455 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752059AbbHYUtN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 16:49:13 -0400
In-Reply-To: <1440354698-11144-1-git-send-email-hdegoede@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hans de Goede <hdegoede@redhat.com>
Date: Sun, 23 Aug 2015 20:31:38 +0200

> Claim the emac sram ourselves, rather then relying on the bootloader
> having mapped the sram to the emac controller during boot.
> 
> Signed-off-by: Hans de Goede <hdegoede@redhat.com>

Applied to net-next, thanks.
