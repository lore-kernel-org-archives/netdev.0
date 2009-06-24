From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] cpmac: fix compilation failure introduced
 with netdev_ops conversion
Date: Wed, 24 Jun 2009 16:32:40 -0700 (PDT)
Message-ID: <20090624.163240.159680261.davem@davemloft.net>
References: <200906241424.48699.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58402
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752147AbZFXXcg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2009 19:32:36 -0400
In-Reply-To: <200906241424.48699.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Date: Wed, 24 Jun 2009 14:24:48 +0200

> This patch fixes and obvious typo in the netdev_ops initialization:
> ndo_so_ioctl should be ndo_do_ioctl.
> 
> Signed-off-by: Florian Fainelli <florian@openwrt.org>

Applied, thanks!
