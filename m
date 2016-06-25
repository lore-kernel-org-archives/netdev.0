From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net: dsa: mv88e6xxx: move driver in its
 own folder
Date: Sat, 25 Jun 2016 11:49:29 -0400 (EDT)
Message-ID: <20160625.114929.15768015737276075.davem@davemloft.net>
References: <20160621162820.11603-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch,
	linux@roeck-us.net
To: vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54296 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751450AbcFYPtf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jun 2016 11:49:35 -0400
In-Reply-To: <20160621162820.11603-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Tue, 21 Jun 2016 12:28:19 -0400

> With the upcoming support for cross-chip operations and other mv88e6xxx
> enhancements, new files will be added.
> 
> Similarly to mlxsw or b53, move mv88e6xxx files into their own folder.
> 
> In the meantime, update the MAINTAINERS entry to please checkpatch.pl,
> by replacing the invalid 88E6352 entry with 88E6XXX, maintained by
> Andrew and myself.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied.
