From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/15][pull request] Intel Wired LAN Driver Updates
 2013.02.16
Date: Mon, 18 Feb 2013 12:37:00 -0500 (EST)
Message-ID: <20130218.123700.1507921010708117768.davem@davemloft.net>
References: <1361003616-3422-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47572 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756484Ab3BRRhC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2013 12:37:02 -0500
In-Reply-To: <1361003616-3422-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat, 16 Feb 2013 00:33:21 -0800

> This series contains updates to e1000, e1000e, igb, igbvf and ixgbe.
> The e1000, e1000e, igb and igbvf are single patch changes and the
> remaining 11 patches are all against ixgbe.
 ...
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next mas=
ter

Pulled.

I trust that Emil will work out the I2C mutex locking issues being
discussed with Micha=A9=A9 Miros=A9=A9aw wrt. patch #13.

Thanks.
