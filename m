From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] net: dsa: mv88e6xxx: add STU capability
Date: Wed, 11 May 2016 19:34:41 -0400 (EDT)
Message-ID: <20160511.193441.455024184360523858.davem@davemloft.net>
References: <1462909469-4827-1-git-send-email-vivien.didelot@savoirfairelinux.com>
	<1462909469-4827-2-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53018 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752411AbcEKXen (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2016 19:34:43 -0400
In-Reply-To: <1462909469-4827-2-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Tue, 10 May 2016 15:44:29 -0400

> Some switch models have a STU (per VLAN port state database). Add a new
> capability flag to switches info, instead of checking their family.
> 
> Also if the 6165 family has an STU, it must have a VTU, so add the
> MV88E6XXX_FLAG_VTU to its family flags.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied.
