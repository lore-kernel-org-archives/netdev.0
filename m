From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] net: dsa: finer bridging control
Date: Mon, 14 Mar 2016 16:05:51 -0400 (EDT)
Message-ID: <20160314.160551.1578011752546252501.davem@davemloft.net>
References: <1457900494-10266-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch,
	jiri@resnulli.us, idosch@mellanox.com, kevin.smith@elecsyscorp.com
To: vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49430 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933257AbcCNUFz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 16:05:55 -0400
In-Reply-To: <1457900494-10266-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Sun, 13 Mar 2016 16:21:31 -0400

> This patchset renames the bridging routines of the DSA layer, make the
> unbridging routine return void, and rework the DSA netdev notifier handler,
> similar to what the Mellanox Spectrum driver does.
> 
> Changes RFC -> v1:
>   - drop unused NETDEV_PRECHANGEUPPER case
>   - add Andrew's Tested-by tag

Series applied, thanks Vivien.
